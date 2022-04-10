#!/usr/bin/env sh
set -e

bundle exec rake db:create db:migrate

mkdir -p /opt/parkings/tmp/pids/
rm -f /opt/parkings/tmp/pids/server.pid
rm -f /opt/parkings/tmp/pids/puma.state

exec "$@"
