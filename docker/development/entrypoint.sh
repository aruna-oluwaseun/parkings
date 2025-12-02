#!/usr/bin/env sh
set -e

echo "Running bundle install..."
bundle install

echo "Running db:create db:migrate..."
bundle exec rake db:create db:migrate

mkdir -p /opt/parkings/tmp/pids/
rm -f /opt/parkings/tmp/pids/server.pid
rm -f /opt/parkings/tmp/pids/puma.state

exec "$@"
