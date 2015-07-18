require 'net/http'
require 'json'

class AuthController < ApplicationController
  # The |login| controller is used to serve up a view presenting the end-user
  # with options for logging in.
  def login
    @providers = Oauth2Provider.all
  end

  # TODO(nharper): Re-do error handling and make it more user friendly.
  def finish
    if !params[:state] || !valid_authenticity_token?(session, params[:state])
      flash[:error] = 'Invalid XSRF token'
      redirect_to error_auth_index_path and return
    end

    @provider = Oauth2Provider.find(params[:id])
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
    @id = JSON.parse(id_resp.body)
  end

  def error
  end
end
