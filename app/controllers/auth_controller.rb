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
    id, error = id_from_code(params[:code], @provider)
    if !id
      flash[:error] = 'There was an error when trying to log in.'
      flash[:error_detail] = error
      redirect_to login_auth_index_path and return
    end

    # Look up the account that matches the id from the OAuth2 provider. It's
    # possible there is no account, if this is a sign-up or link flow.
    account = UserOauth2Account.where(:oauth2_provider => @provider, :provider_id => id).first
    if session[:new_user_id]
      new_user = User.find(session[:new_user_id])
    end

    if account
      # Log in the current user
      session[:user_id] = account.user_id
      return redirect_after_login
    # In case I forget when looking at this code later, current_user is a method
    # defined on ApplicationController. (It's not a local variable.)
    elsif current_user || new_user
      if new_user
        new_user.clear_login_token
        user = new_user
        session[:user_id] = session[:new_user_id]
        session.delete :new_user_id
      else
        user = current_user
      end
      if UserOauth2Account.create(
          :oauth2_provider => @provider,
          :provider_id => id,
          :user => user)
        return redirect_after_login
      else
        flash[:error] = "There was an error trying to link #{@provider.name} account."
        redirect_to login_auth_index_path and return
      end
    end

    flash[:error] = 'Unable to find any user account for that login.'
    redirect_to login_auth_index_path
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
    token_uri = URI(provider[:token_url])
    token_conn = Net::HTTP.new(token_uri.host, 443)
    token_conn.use_ssl = true
    data = {
      :code => code,
      :client_id => provider[:client_id],
      :client_secret => provider[:client_secret],
      :redirect_uri => url_for(:action => 'finish'),
      :grant_type => 'authorization_code',
    }.to_query
    token_resp = token_conn.post(token_uri.path, data)

    if token_resp.code != '200'
      return nil, "Unexpected HTTP status #{token_resp.code} getting token"
    end

    token_json = JSON.parse(token_resp.body)
    access_token = token_json['access_token']
    if !access_token
      return nil, "No access_token in response"
    end

    id_uri = URI(provider[:id_url])
    id_uri.query = {
      :access_token => access_token
    }.to_query
    id_conn = Net::HTTP.new(id_uri.host, 443)
    id_conn.use_ssl = true
    id_resp = id_conn.get(id_uri.to_s)
    if id_resp.code != '200'
      return nil, "Unexpected HTTP status #{id_resp.code} getting user id"
    end

    begin
      id_json = JSON.parse(id_resp.body)
    rescue JSON::ParserError
      return nil, "Failed to parse ID from response"
    end
    id = id_json['id']
    if !id || id.length == 0
      return nil, "Failed to parse ID from response"
    end

    return id, nil
  end
end
