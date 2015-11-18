require 'oauth2'
require 'omniauth'
require 'securerandom'
require 'socket'       # for SocketError
require 'timeout'      # for Timeout::Error
require 'faraday'      # for Faraday::Error::TimeoutError and Faraday::Error::ConnectionFailed
require 'multi_json'   # for MultiJson::DecodeError

module OmniAuth
  module Strategies
    class Oauth2Password
      include OmniAuth::Strategy

      args [:client_id, :client_secret]

      option :client_id, nil
      option :client_secret, nil
      option :client_options, {:site => ENV['OAUTH_APP_URL']}
      option :authorize_params, {}
      option :authorize_options, [:scope]
      option :token_params, {}
      option :token_options, []
      option :auth_token_params, {}
      option :provider_ignores_state, false

      attr_accessor :access_token

      def client
        ::OAuth2::Client.new(options.client_id, options.client_secret, deep_symbolize(options.client_options))
      end

      def callback_url
        full_host + script_name + callback_path
      end

      credentials do
        hash = {'token' => access_token.token}
        hash.merge!('refresh_token' => access_token.refresh_token) if access_token.expires? && access_token.refresh_token
        hash.merge!('expires_at' => access_token.expires_at) if access_token.expires?
        hash.merge!('expires' => access_token.expires?)
        hash
      end

      def request_phase
        redirect client.connection.build_url(callback_url, authorize_params.merge('username' => request.params['username'], 'password' => request.params['password'])).to_s
      end

      def authorize_params
        options.authorize_params.merge(options_for('authorize'))
      end

      def token_params
        options.token_params.merge(options_for('token'))
      end

      def callback_phase
        self.access_token = build_access_token
        self.access_token = access_token.refresh! if access_token.expired?
        super
      rescue ::OAuth2::Error, CallbackError => e
        fail!(:invalid_credentials, e)
      rescue ::MultiJson::DecodeError => e
        fail!(:invalid_response, e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT, Faraday::Error::TimeoutError => e
        fail!(:timeout, e)
      rescue ::SocketError, Faraday::Error::ConnectionFailed => e
        fail!(:failed_to_connect, e)
      end

    protected

      def build_access_token
        client.password.get_token(request.params['username'], request.params['password'], {:redirect_uri => callback_url}.merge(token_params.to_hash(:symbolize_keys => true)), deep_symbolize(options.auth_token_params))
      end

      def deep_symbolize(options)
        hash = {}
        options.each do |key, value|
          hash[key.to_sym] = value.is_a?(Hash) ? deep_symbolize(value) : value
        end
        hash
      end

      def options_for(option)
        hash = {}
        options.send(:"#{option}_options").select { |key| options[key] }.each do |key|
          hash[key.to_sym] = options[key]
        end
        hash
      end

      # An error that is indicated in the OAuth 2.0 callback.
      # This could be a `redirect_uri_mismatch` or other
      class CallbackError < StandardError
        attr_accessor :error, :error_reason, :error_uri

        def initialize(error, error_reason = nil, error_uri = nil)
          self.error = error
          self.error_reason = error_reason
          self.error_uri = error_uri
        end

        def message
          [error, error_reason, error_uri].compact.join(' | ')
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'oauth2', 'OAuth2'
