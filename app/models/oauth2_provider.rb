class Oauth2Provider < ActiveRecord::Base
  def to_param
    return self.slug
  end

  serialize :auth_params, JSON

  has_many :user_oauth2_accounts

  # Takes an authorization_code and returns an access_token and refresh_token.
  def exchange_authorization_code(code, redirect_uri)
    return exchange_token({
      :code => code,
      :redirect_uri => redirect_uri,
      :grant_type => 'authorization_code',
    })
  end

  # Takes a refresh_token and returns an access_token.
  def refresh_token(refresh_token)
    return exchange_token({
      :refresh_token => refresh_token,
      :grant_type => 'refresh_token',
    })['access_token']
  end

  # Takes an access_token and makes a request to self.id_url
  def get_id(access_token)
    id_uri = URI(self.id_url)
    id_uri.query = { :access_token => access_token }.to_query
    id_conn = Net::HTTP.new(id_uri.host, 443)
    id_conn.use_ssl = true
    id_resp = id_conn.get(id_uri.to_s)
    if id_resp.code != '200'
      raise "Unexpected HTTP status #{id_resp.code} getting id"
    end
    id_json = JSON.parse(id_resp.body)
    id = id_json['id']
    if !id || id.length == 0
      raise "Failed to parse ID from response"
    end
    return id
  end

 private
  def exchange_token(params)
    token_uri = URI(self.token_url)
    token_conn = Net::HTTP.new(token_uri.host, 443)
    token_conn.use_ssl = true
    params = params.merge({
      :client_id => self.client_id,
      :client_secret => self.client_secret,
    })
    token_resp = token_conn.post(token_uri.path, params.to_query)

    if token_resp.code != '200'
      raise "Unexpected HTTP status code #{token_resp.code} exchanging token"
    end

    token_json = JSON.parse(token_resp.body)
    if !token_json['access_token']
      raise "Response did not contain tokens: #{token_resp.body}"
    end

    return token_json
  end
end
