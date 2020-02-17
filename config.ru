require 'rack'
require 'rack/protection'
require 'securerandom'
require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq-scheduler'
require 'sidekiq-scheduler/web'
require 'sidekiq-status'
require 'sidekiq-status/web'

# Default environment variables
ENV['SESSION_SECRET'] ||= SecureRandom.hex(64)
ENV['ORIGIN_WHITELIST'] ||= '*'
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

# Configure middleware
use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']
use Rack::Protection, origin_whitelist: ENV['ORIGIN_WHITELIST'].split(',')

# Run the server
run Sidekiq::Web
