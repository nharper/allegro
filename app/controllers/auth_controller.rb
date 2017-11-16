require 'net/http'
require 'json'

class AuthController < ApplicationController
  skip_before_filter :require_login, :except => [:token]

  # The |login| controller is used to serve up a view presenting the end-user
  # with options for logging in. The same view is also used for a new user
  # linking an account for the first time.
  def login
    # Only use a login token if there is no user logged in.
    if params[:token] && !session[:user_id]
      user = User.find_by_login_token(params[:token])
      if user == nil
        flash[:error] = 'Login link is invalid.'
      else
        # Note this key is different than in the if - :new_user_id puts the user
        # in an half-logged-in state - they aren't actually logged in, but we'll
        # still remember who they are so they can finish the sign-up flow.
        session[:new_user_id] = user.id
      end
    end
    @providers = Oauth2Provider.all
  end

  def finish
    if !params[:state] || !valid_authenticity_token?(session, params[:state])
      flash[:error] = 'There was an error when trying to log in.'
      flash[:error_detail] = 'Invalid XSRF token.'
      redirect_to login_auth_index_path and return
    end

    if params[:error]
      # This likely means that the user cancelled the auth request (instead of
      # accepting).
      flash[:error] = 'There was an error when trying to log in.'
      flash[:error_detail] = 'Failed to obtain access code.'
      redirect_to login_auth_index_path and return
    end

    @provider = Oauth2Provider.where(:slug => params[:id]).first
    # Get the user id from the OAuth2 provider using the code provided.
    id = nil
    tokens = nil
    begin
      tokens = @provider.exchange_authorization_code(
          params[:code], url_for(:action => 'finish'))
      id = @provider.get_id(tokens['access_token'])
    rescue Exception => e
      err = e.to_s
    end
    if !id && !err
      err = 'No ID found'
    end
    if err
      flash[:error] = 'There was an error when trying to log in.'
      flash[:error_detail] = err
      redirect_to login_auth_index_path and return
    end

    # Look up the account that matches the id from the OAuth2 provider. It's
    # possible there is no account, if this is a sign-up or link flow.
    account = UserOauth2Account.where(:oauth2_provider => @provider, :provider_id => id).first
    if !account
      if session[:new_user_id]
        session[:user_id] = session[:new_user_id]
        session.delete :new_user_id
      end
      if !session[:user_id]
        flash[:error] = 'Unable to find any user account for that login.'
        redirect_to login_auth_index_path and return
      end
      account = UserOauth2Account.new(
        :oauth2_provider => @provider,
        :provider_id => id,
        :user => current_user,
      )
    end

    # Log in the current user
    session[:user_id] = account.user_id

    # Save the access/refresh tokens
    account.access_token = tokens['access_token']
    if tokens['refresh_token']
      account.refresh_token = tokens['refresh_token']
    end
    account.save

    redirect_after_login
  end

  def logout
    reset_session
    redirect_to login_auth_index_path
  end

  def token
    render :plain => form_authenticity_token
  end

  def dev_login
    if Rails.env.development?
      session[:user_id] = 1
    end
    redirect_to '/'
  end

 private
  def id_from_code(code, provider)
    begin
      tokens = provider.exchange_authorization_code(
          code, url_for(:action => 'finish'))
      provider.get_id(tokens['access_token'])
    rescue Exception => e
      return nil, e.to_s
    end
  end
end
