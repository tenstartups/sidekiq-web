#!/bin/bash
set -e

if [ -z "$@" ]; then
  bundle exec puma --environment "${APP_ENV}" --bind "tcp://0.0.0.0:${PORT}"  ./config.ru
else
  exec "$@"
fi
