require 'net/http'
require 'json'

class AuthController < ApplicationController
  # The |login| controller is used to serve up a view presenting the end-user
  # with options for logging in.
  def login
    # TODO(nharper): If a user logs in with a token, they should get directed
    # to link a provided identity with their account (and don't delete their
    # one-time use token until that's done).
    #
    # Perhaps instead of immediately logging them in, put the user id in a
    # different part of the session that this controller uses (but everthing
    # else will ignore), so the user doesn't continually use the token link to
    # log in.
    if params[:token] && !session[:user_id]
      user = User.find_by_login_token(params[:token])
      session[:user_id] = user.id
      redirect_to '/' and return
    end
    @providers = Oauth2Provider.all
  end

  # TODO(nharper): Re-do error handling and make it more user friendly.
  def finish
    if !params[:state] || !valid_authenticity_token?(session, params[:state])
      flash[:error] = 'Invalid XSRF token'
      redirect_to error_auth_index_path and return
    end

    @provider = Oauth2Provider.where(:slug => params[:id]).first
    if params[:error]
      flash[:error] = 'Failed to obtain access code'
      flash[:error_code] = params[:error]
      redirect_to error_auth_index_path and return
    end

    token_uri = URI(@provider[:token_url])
    token_conn = Net::HTTP.new(token_uri.host, 443)
    token_conn.use_ssl = true
    data = {
      :code => params[:code],
      :client_id => @provider[:client_id],
      :client_secret => @provider[:client_secret],
      :redirect_uri => url_for(:action => 'finish'),
      :grant_type => 'authorization_code',
    }.to_query
    token_resp = token_conn.post(token_uri.path, data)

    if token_resp.code != '200'
      flash[:error] = 'Unexpected response trading code for token'
      flash[:error_code] = token_resp.code
      flash[:error_details] = token_resp.body
      redirect_to error_auth_index_path and return
    end

    token_json = JSON.parse(token_resp.body)
    access_token = token_json['access_token']
    if !access_token
      flash[:error] = 'Failed to parse access_token from JSON response'
      flash[:error_code] = access_token
      flash[:error_details] = token_resp.body
      redirect_to error_auth_index_path and return
    end

    id_uri = URI(@provider[:id_url])
    id_uri.query = {
      :access_token => access_token
    }.to_query
    id_conn = Net::HTTP.new(id_uri.host, 443)
    id_conn.use_ssl = true
    id_resp = id_conn.get(id_uri)
    if id_resp.code != '200'
      flash[:error] = 'Unexpected error getting user\'s id with token'
      flash[:error_code] = id_resp.code
      flash[:error_details] = id_resp.body
      redirect_to error_auth_index_path and return
    end

    # This is just a placeholder while testing that the OAuth2 implementation
    # works correctly.
    #
    # This should be changed to look up the (provider, id) pair to see if it
    # corresponds to an existing user. It should also look at the current
    # session and see if a user is currently logged in. There are 4 possible
    # combinations:
    # +-----------------+-------------------+-----------------------------+
    # | session user id | oauth provided id |                             |
    # +=================+===================+=============================+
    # | absent          | absent            | sign-up form                |
    # +-----------------+-------------------+-----------------------------+
    # | absent          | present           | log in user                 |
    # +-----------------+-------------------+-----------------------------+
    # | present         | absent            | link provided id to account |
    # +-----------------+-------------------+-----------------------------+
    # | present         | present           | error (do nothing if match) |
    # +-----------------+-------------------+-----------------------------+

    begin
      id_json = JSON.parse(id_resp.body)
    rescue JSON::ParserError
      flash[:error] = 'Unable to parse response from provider server'
      flash[:error_code] = id_resp.body
      redirect_to error_auth_index_path and return
    end
    id = id_json['id']
    if !id || id.length == 0
      flash[:error] = 'No ID in response from server'
      redirect_to error_auth_index_path and return
    end
    # TODO(nharper): Turn everything above into a helper method that turns a
    # code into an id, returning the id and an error message.

    account = UserOauth2Account.where(:oauth2_provider => @provider, :provider_id => id_json['id']).first
    current_user = User.find(session[:user_id])

    if account && !current_user
      puts "Found account; no current user is logged in"
      # Log in the current user
      session[:user_id] = account.user_id
      redirect_to '/' and return
    elsif current_user && !account
      puts "Current user is logged in; linking account"
      new_account = UserOauth2Account.new
      new_account.oauth2_provider = @provider
      new_account.provider_id = id
      new_account.user = current_user
      new_account.save
      p new_account
      redirect_to '/' and return
    end

    p account
    p current_user
    redirect_to error_auth_index_path
  end

  def error
  end

  def logout
    session = nil
    redirect_to '/'
  end
end
