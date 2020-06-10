#!/bin/sh
set -e

# Clean up phantom pids
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

exec "$@"
