require 'net/http'
require 'json'

class AuthController < ApplicationController
  @@provider = {
    :auth_url => 'https://accounts.google.com/o/oauth2/auth',
    :token_url => 'https://www.googleapis.com/oauth2/v3/token',
    :id_url => 'https://www.googleapis.com/userinfo/v2/me',
    :client_id => '72492558211-eb3dk55jnqkq43jtih6bmi9vh7uos65i.apps.googleusercontent.com',
    :client_secret => '0u5L2VseZSLjE-QMXUn_KbaF',
    :scope => 'profile',
    :extra_params => {
      :response_type => 'code',
    }
  }
#  @@provider = {
#    :auth_url => 'https://www.facebook.com/dialog/oauth',
#    :token_url => 'https://graph.facebook.com/v2.4/oauth/access_token',
#    :id_url => 'https://graph.facebook.com/v2.4/me',
#    :client_id => '569288896545840',
#    :client_secret => 'c97f0b7a046618d8a57a3a9b89001743',
#    :scope => '',
#  }
  def login_redirect
    redirect_uri = URI(@@provider[:auth_url])
    redirect_uri.query = {
      'client_id' => @@provider[:client_id],
      'redirect_uri' => url_for(:action => 'finish'),
      'scope' => @@provider[:scope],
    }.merge(@@provider[:extra_params]||{}).to_query
    redirect_to redirect_uri.to_s
  end

  def finish
    if params[:error]
      redirect_to :action => 'error' and return
    end

    token_uri = URI(@@provider[:token_url])
    token_conn = Net::HTTP.new(token_uri.host, 443)
    token_conn.use_ssl = true
    data = {
      :code => params[:code],
      :client_id => @@provider[:client_id],
      :client_secret => @@provider[:client_secret],
      :redirect_uri => url_for(:action => 'finish'),
      :grant_type => 'authorization_code',
    }.to_query
    token_resp = token_conn.post(token_uri.path, data)

    if token_resp.code != '200'
      flash[:error] = 'Unexpected response trading code for token'
      flash[:error_code] = token_resp.code
      flash[:error_details] = token_resp.body
      redirect_to :action => 'error' and return
    end

    token_json = JSON.parse(token_resp.body)
    access_token = token_json['access_token']
    if !access_token
      flash[:error] = 'Failed to parse access_token from JSON response'
      flash[:error_code] = access_token
      flash[:error_details] = token_resp.body
      redirect_to :action => 'error' and return
    end

    id_uri = URI(@@provider[:id_url])
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
      redirect_to :action => 'error' and return
    end

    p JSON.parse(id_resp.body)
  end

  def error
  end
end
