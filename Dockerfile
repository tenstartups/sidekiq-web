#
# Sidekiq monitor web application with scheduler and status gem extension.
#

FROM ruby:alpine

# Set environment variables.
ENV \
  APP_ENV=production \
  BUNDLE_DISABLE_SHARED_GEMS=true \
  BUNDLE_FROZEN=true \
  BUNDLE_GIT__ALLOW_INSECURE=true \
  BUNDLE_IGNORE_MESSAGES=true \
  BUNDLE_PATH=/usr/local/lib/ruby/bundler \
  PORT=9292

# Install packages.
RUN apk --update add bash build-base git nodejs && rm -rf /var/cache/apk/*

# Install required ruby gems.
RUN gem install bundler

# Set the working directory.
WORKDIR /usr/src/app

# Copy Gemfile into place.
COPY Gemfile ./
COPY Gemfile.lock ./

# Bundle the gems.
RUN bundle install
#RUN sh -c "cat ./Gemfile.lock"

# Copy the remaining files into place.
COPY entrypoint.sh /docker-entrypoint
COPY config/puma.rb config/puma.rb
COPY config.ru ./
COPY healthcheck.js ./

ARG APP_UID=1001
ARG APP_GID=1001
RUN addgroup -g "${APP_GID}" -S app \
  && adduser -u "${APP_UID}" -S -G app -h /usr/src/app -D app \
  && chown -R app:app /usr/src/app /docker-entrypoint \
  && chmod +x /docker-entrypoint ./healthcheck.js \
  && chmod -R a+rX /usr/local/lib/ruby/bundler

# Expose the standard rack port.
EXPOSE ${PORT}

# Define the healthcheck.
HEALTHCHECK --interval=15s --timeout=5s CMD "./healthcheck.js"

# Set the entrypoint script.
ENTRYPOINT ["/docker-entrypoint"]

USER app:app
