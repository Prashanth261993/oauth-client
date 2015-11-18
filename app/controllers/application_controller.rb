class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from OAuth2::Error do |exception|
    if exception.response.status == 401
      session[:user_id] = nil
      session[:access_token] = nil
      redirect_to login_url, alert: 'The username or password you have entered is wrong. Please try again.'
    end
  end

  def oauth_client
    @client ||= OAuth2::Client.new(ENV['OAUTH_APP_ID'], ENV['OAUTH_APP_SECRET'], :site => ENV['OAUTH_APP_URL'])
  end

  def oauth_access_token
    @token ||= OAuth2::AccessToken.new(oauth_client, current_user.access_token) if current_user
  end

  def require_login
    redirect_to login_url and return false unless user_signed_in?
  end

  def user_signed_in?
    current_user.present?
  end
  helper_method :user_signed_in?

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end
