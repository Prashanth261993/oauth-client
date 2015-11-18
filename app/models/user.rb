class User < ActiveRecord::Base

  validates :name, :email, :provider, :uid, :access_token, :presence => true
  validates :name, length: { maximum: 50 }
  validates :email, :access_token, uniqueness: true
  validates :provider, uniqueness: { :scope => :uid }

  def self.build_auth_hash( access_token )
    _raw_info = raw_info(access_token)

    hash = OmniAuth::AuthHash.new(:provider => 'oauth2_password', :uid => _raw_info['id'])
    hash.info = { :name => _raw_info['name'], :email => _raw_info['email'] }
    hash.credentials = credentials( access_token )
    hash.extra = {'raw_info' => _raw_info}

    hash
  end

  def self.raw_info( access_token )
    access_token.get('/users/me.json').parsed
  end

  def self.credentials( access_token )
    hash = {'token' => access_token.token}
    hash.merge!('refresh_token' => access_token.refresh_token) if access_token.expires? && access_token.refresh_token
    hash.merge!('expires_at' => access_token.expires_at) if access_token.expires?
    hash.merge!('expires' => access_token.expires?)
    hash
  end

  def self.from_omniauth( auth )
    user = User.where( email: auth.info.email ).first_or_initialize

    user.provider = auth.provider
    user.uid = auth.uid
    user.name = auth.info.name
    user.access_token = auth['credentials']['token']

    user.save!
    user
  end
end
