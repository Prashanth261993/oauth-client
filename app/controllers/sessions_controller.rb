class SessionsController < ApplicationController
  def new

  end

  def authenticate
    client = OAuth2::Client.new( ENV['OAUTH_APP_ID'], ENV['OAUTH_APP_SECRET'], :site => ENV['OAUTH_APP_URL'] )

    email = params[:session][:email]
    password = params[:session][:password]
    access_token = client.password.get_token( email, password )
    env['omniauth.auth'] = User.build_auth_hash( access_token )

    auth = request.env['omniauth.auth']
    user = User.from_omniauth( auth )
    session[:user_id] = user.id
    redirect_to( root_url, notice: 'Signed in!' )
  end


  def create
    auth = request.env['omniauth.auth']
    user = User.from_omniauth( auth )
    session[:user_id] = user.id
    redirect_to( root_url, notice: 'Signed in!' )
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: 'Signed out!'
  end

end
