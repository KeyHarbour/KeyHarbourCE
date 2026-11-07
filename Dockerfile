# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t key_harbour_ee .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name key_harbour_ee key_harbour_ee

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=4.0.9
FROM docker.io/library/ruby:$RUBY_VERSION-alpine AS base

ARG PORT=3000
# Rails app lives here
WORKDIR /rails

# Install base packages (Alpine equivalents of curl, libjemalloc2, libvips, postgresql-client + tzdata/bash)
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
      bash \
      curl \
      jemalloc \
      openssl \
      postgresql-client \
      tzdata \
      vips && \
    ln -s /usr/lib/libjemalloc.so.2 /usr/local/lib/libjemalloc.so

# Set production environment variables and enable jemalloc for reduced memory usage and latency.
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems (Alpine equivalents of build-essential, git, libpq-dev, libvips, libyaml-dev, pkg-config)
RUN apk add --no-cache \
      build-base \
      git \
      gcompat \
      postgresql-dev \
      vips-dev \
      yaml-dev

# Install application gems
COPY vendor/* ./vendor/
COPY Gemfile Gemfile.lock ./

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    # -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
    bundle exec bootsnap precompile -j 1 --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times.
# -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
RUN bundle exec bootsnap precompile -j 1 app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# Final stage for app image
FROM base

# Run and own only the runtime files as a non-root user for security (Alpine addgroup/adduser)
RUN addgroup -g 1000 -S rails && \
    adduser -u 1000 -S rails -G rails -s /bin/bash
USER 1000:1000

# Copy built artifacts: gems, application
COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

EXPOSE ${PORT}
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# # Start server via Thruster by default, this can be overwritten at runtime
# EXPOSE 80
# CMD ["./bin/thrust", "./bin/rails", "server"]
