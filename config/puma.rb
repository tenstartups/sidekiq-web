# frozen_string_literal: true

workers ENV.fetch("WEB_CONCURRENCY", 2).to_i

threads_count = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
threads threads_count, threads_count

environment ENV.fetch("APP_ENV", "production")
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 9292)}"

# Load config.ru once in the master so forked workers share ENV (e.g. SESSION_SECRET).
preload_app!
