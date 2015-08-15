class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :require_login

 private
  def require_login
    unless is_logged_in?
      session[:redirect_path] = request.fullpath
      redirect_to login_auth_index_path
    end
  end

  def redirect_after_login
    path = '/'
    if session[:redirect_path]
      path = session[:redirect_path]
    end
    redirect_to path
  end

  def is_logged_in?
    return !!current_user
  end

  def current_user
    return User.find_by_id(session[:user_id])
  end
end
