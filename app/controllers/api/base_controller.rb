class Api::BaseController < ApplicationController
  skip_before_action :require_login
  before_action :check_credentials

 private
  def check_credentials
    return if is_logged_in?
    render :json => {error: 'Authorization required'}, :status => 403
  end
end
