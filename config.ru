require 'rack'
require 'securerandom'
require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq-scheduler'
require 'sidekiq-scheduler/web'
require 'sidekiq-status'
require 'sidekiq-status/web'

require 'rack/protection'

module Rack
  module Protection
    ##
    # Prevented attack::   CSRF
    # Supported browsers:: Google Chrome 2, Safari 4 and later
    # More infos::         http://en.wikipedia.org/wiki/Cross-site_request_forgery
    #                      http://tools.ietf.org/html/draft-abarth-origin
    #
    # Does not accept unsafe HTTP requests when value of Origin HTTP request header
    # does not match default or whitelisted URIs.
    #
    # If you want to whitelist a specific domain, you can pass in as the `:origin_whitelist` option:
    #
    #     use Rack::Protection, origin_whitelist: ["http://localhost:3000", "http://127.0.01:3000"]
    #
    # The `:allow_if` option can also be set to a proc to use custom allow/deny logic.
    class HttpOrigin < Base
      def accepts?(env)
        puts "Origin = #{env['HTTP_ORIGIN']}"
        puts "Base URL = #{base_url(env)}"
        return true if safe? env
        return true unless origin = env['HTTP_ORIGIN']
        return true if base_url(env) == origin
        return true if options[:allow_if] && options[:allow_if].call(env)
        Array(options[:origin_whitelist]).include? origin
      end

    end
  end
end

# Default environment variables
ENV['SESSION_SECRET'] ||= SecureRandom.hex(64)
ENV['REDIS_URL'] ||= 'redis://redis'

# Set external encoding to avoid invalid byte sequence when displaying unicode
Encoding.default_external = Encoding::UTF_8

# Configure client
Sidekiq.configure_client do |config|
  config.redis =
    if ENV['REDIS_NAMESPACE'].nil?
      { url: ENV['REDIS_URL'] }
    else
      {
        url: ENV['REDIS_URL'],
        namespace: ENV['REDIS_NAMESPACE']
      }
    end
end

# Set the session secret
Sidekiq::Web.set :session_secret, ENV['SESSION_SECRET']

# # Configure rack middleware
# Sidekiq::Web.class_eval do
#   use Rack::Protection, except: :http_origin
# end

# Run the server
run Sidekiq::Web
