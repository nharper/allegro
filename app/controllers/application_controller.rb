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
    if !current_user
      return false
    end
    if !current_user.permissions
      return true
    end
    return !(current_user.permissions['disabled'] === true)
  end

  def current_user
    return User.find_by_id(session[:user_id])
  end

  def user_can_send_emails
    return current_user.permissions && current_user.permissions['sends_mail_as']
  end

  helper_method :user_can_send_emails

  def send_email(message, sender)
    send_message_uri = URI("https://www.googleapis.com/upload/gmail/v1/users/me/messages/send?uploadType=media")
    mailer_conn = Net::HTTP.new(send_message_uri.host, 443)
    mailer_conn.use_ssl = true

    headers = {
      'Authorization' => "Bearer #{sender.access_token}",
      'Content-Type' => 'message/rfc822',
    }
    mail_resp = mailer_conn.post(send_message_uri.path, message, headers)
    if mail_resp.code != '200'
      sender.update_access_token
    end
    headers = {
      'Authorization' => "Bearer #{sender.access_token}",
      'Content-Type' => 'message/rfc822',
    }
    mail_resp = mailer_conn.post(send_message_uri.path, message, headers)
    if mail_resp.code != '200'
      flash[:error_details] = mail_resp.body
      return false
    end
    return true
  end
end
