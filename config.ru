require 'rack'
require 'securerandom'
require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq/cron'
require 'sidekiq/cron/web'
# require 'sidekiq_unique_jobs'
# require 'sidekiq_unique_jobs/web'

# Default environment variables
ENV['SESSION_SECRET'] ||= SecureRandom.hex(64)
if ENV.key?('SENTINEL_HOSTS').nil?
  ENV['REDIS_URL'] ||= 'redis://redis'
else
  ENV['SENTINEL_HOST'] ||= 'mymaster'
  ENV['SENTINEL_PORT'] ||= 26_379
end

# Set external encoding to avoid invalid byte sequence when displaying unicode
Encoding.default_external = Encoding::UTF_8

# Configure client
Sidekiq.configure_client do |config|
  if ENV.key?('SENTINEL_HOSTS').nil?
    config.redis = { url: ENV['REDIS_URL'] }
  else
    config.redis = {
      host: ENV['SENTINEL_HOST'],
      password: ENV['REDIS_PASSWORD'],
      sentinels: ENV['SENTINEL_HOSTS'].split.map! do |host|
        { host: host, port: ENV['SENTINEL_PORT'] }
      end
    }
  end
end

# Set the session cookie middleware
use Rack::Session::Cookie, secret: ENV['SESSION_SECRET'], same_site: true, max_age: 86_400

# Set the session secret
Sidekiq::Web.set :session_secret, ENV['SESSION_SECRET']

# Run the server
run Sidekiq::Web
