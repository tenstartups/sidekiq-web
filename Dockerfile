#
# Sidekiq monitor web application with scheduler and status gem extension.
#

FROM ruby:2.6-alpine

# Set environment variables.
ENV \
  BUNDLE_DISABLE_SHARED_GEMS=true \
#  BUNDLE_FROZEN=true \
  BUNDLE_GIT__ALLOW_INSECURE=true \
  BUNDLE_IGNORE_MESSAGES=true \
  BUNDLE_PATH=/usr/local/lib/ruby/bundler \
  BUNDLE_SILENCE_ROOT_WARNING=true

# Install packages.
RUN apk --update add build-base nodejs && rm -rf /var/cache/apk/*

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
COPY config.ru ./
COPY healthcheck.js ./

# Expose the standard rack port.
EXPOSE 9292

# Define the healthcheck.
HEALTHCHECK --interval=15s --timeout=5s CMD "./healthcheck.js"

# Define the default command.
CMD ["bundle", "exec", "puma"]
