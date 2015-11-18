require File.expand_path('lib/omniauth/strategies/reportbee', Rails.root)
# require File.expand_path('lib/omniauth/strategies/oauth2_password', Rails.root)

OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :reportbee, ENV['OAUTH_APP_ID_FOR_CODE_FLOW'], ENV['OAUTH_APP_SECRET_FOR_CODE_FLOW']
  # provider :oauth2_password, ENV['OAUTH_APP_ID'], ENV['OAUTH_APP_SECRET']
end
