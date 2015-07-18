module AuthHelper
  def login_redirect_uri(provider)
    redirect_uri = URI(provider[:auth_url])
    redirect_uri.query = {
      'state' => form_authenticity_token,
      'client_id' => provider[:client_id],
      'redirect_uri' => finish_auth_url(provider)
    }.merge(provider[:auth_params]||{}).to_query
    return redirect_uri.to_s
  end
end
