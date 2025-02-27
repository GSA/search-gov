ARG RUBY_VERSION=3.3.4
FROM public.ecr.aws/docker/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl libjemalloc2 libcurl4-openssl-dev default-libmysqlclient-dev chromium-driver sendmail && \
    apt-get clean

# Set production environment
ENV RAILS_ENV="production" \
    RAILS_LOG_TO_STDOUT="1" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Install JavaScript dependencies | Needed in base due coffee-rails gem
ARG NODE_VERSION=20.10.0
ARG YARN_VERSION=latest
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    rm -rf /tmp/* /usr/local/share/.cache

# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems and node modules
RUN apt-get install --no-install-recommends -y build-essential git libvips pkg-config

# Install JavaScript dependencies
RUN npm install -g yarn@$YARN_VERSION && rm -rf /tmp/node-build-master

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node modules
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# AWS access for assets compilation
ARG ASSET_HOST
ARG AWS_ACCESS_KEY_ID
ARG AWS_REGION
ARG AWS_S3_BUCKET
ARG AWS_SECRET_ACCESS_KEY

ENV ASSET_HOST=${ASSET_HOST} \
    AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    AWS_REGION=${AWS_REGION} \
    AWS_S3_BUCKET=${AWS_S3_BUCKET} \
    AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE=1 ./bin/rails assets:precompile

# Final stage for app image
FROM base

# Clean up installation packages to reduce image size
RUN rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

RUN bin/secure_docker

USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

ENV PORT=${PORT:-3000}
EXPOSE ${PORT}

# Start the server by default, this can be overwritten at runtime
CMD ./bin/rails server -p ${PORT}
