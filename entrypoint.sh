#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /webapp/tmp/pids/server.pid

# initial commands
if [ "$RAILS_ENV" = "development" ]; then
    bundle install
    yarn install
fi

bundle exec rails db:create
bundle exec rails db:migrate
#bundle exec rails db:seed

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"

