class AuthController < ApplicationController
  @@provider = {
    :auth_url => 'https://www.facebook.com/dialog/oauth',
    :client_id => '133718410079849',
  }
  def login_redirect
    callback_uri = url_for :action => 'finish'
    p callback_uri

    redirect_uri = URI(@@provider[:auth_url])
    redirect_uri.query = {
      'client_id' => @@provider[:client_id],
      'redirect_uri' => callback_uri
    }.to_query
    redirect_to redirect_uri.to_s
  end

  def finish
  end
end
