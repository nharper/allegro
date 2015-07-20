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

  def finish
    if !params[:state] || !valid_authenticity_token?(session, params[:state])
      flash[:error] = 'Invalid XSRF token'
      redirect_to error_auth_index_path and return
    end

    if params[:error]
      # This likely means that the user cancelled the auth request (instead of
      # accepting).
      flash[:error] = 'Failed to obtain access code'
      redirect_to error_auth_index_path and return
    end

    @provider = Oauth2Provider.where(:slug => params[:id]).first
    id, error = id_from_code(params[:code], @provider)
    if !id
      flash[:error] = error
      redirect_to error_auth_index_path and return
    end

    account = UserOauth2Account.where(:oauth2_provider => @provider, :provider_id => id).first
    current_user = User.find(session[:user_id])

    if account && !current_user
      puts "Found account; no current user is logged in"
      # Log in the current user
      session[:user_id] = account.user_id
      redirect_to '/' and return
    elsif current_user && !account
      puts "Current user is logged in; linking account"
      if UserOauth2Account.create(
          :oauth2_provider => @provider,
          :provider_id => id,
          :user => current_user)
        redirect_to '/' and return
      else
        flash[:error] = "Unable to link #{@provider.name} account"
        redirect_to error_auth_index_path and return
      end
    end

    redirect_to error_auth_index_path
  end

  def error
  end

  def logout
    session = nil
    redirect_to '/'
  end

 private
  # TODO(nharper): Consider making error messages here more user-friendly.
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
    id_resp = id_conn.get(id_uri)
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
