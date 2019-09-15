#
# Sidekiq monitor web application
#
# Alpine based sidekiq monitor web application with scheduler gem extension
#
# http://github.com/tenstartups/sidekiq-web
#

FROM ruby:alpine

RUN apk --update add nodejs && rm -rf /var/cache/apk/*

RUN gem install rack redis-namespace sidekiq sidekiq-scheduler sidekiq-status tzinfo-data

COPY config.ru config.ru
COPY healthcheck.js healthcheck.js

EXPOSE 9292

# Define the healthcheck.
HEALTHCHECK --interval=15s --timeout=5s CMD "node healthcheck.js"

CMD rackup config.ru --host 0.0.0.0
