#
# Sidekiq monitor web application
#
# Alpine based sidekiq monitor web application with scheduler gem extension
#
# http://github.com/tenstartups/sidekiq-web
#

FROM ruby:alpine

RUN gem install rack redis-namespace sidekiq sidekiq-scheduler sidekiq-status tzinfo-data

COPY config.ru config.ru

EXPOSE 9292

# Define the healthcheck.
HEALTHCHECK --interval=15s --timeout=5s CMD "wget http://localhost:9292/stats"

CMD rackup config.ru --host 0.0.0.0
