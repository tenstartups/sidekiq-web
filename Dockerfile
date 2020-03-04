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
  BUNDLE_SILENCE_ROOT_WARNING=true \
  PORT=9292

# Install packages.
RUN apk --update add bash build-base nodejs && rm -rf /var/cache/apk/*

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
COPY config.ru ./
COPY healthcheck.js ./

# Expose the standard rack port.
EXPOSE ${PORT}

# Define the healthcheck.
HEALTHCHECK --interval=15s --timeout=5s CMD "./healthcheck.js"

# Set the entrypoint script.
ENTRYPOINT ["/docker-entrypoint"]
