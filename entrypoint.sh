#!/bin/bash
set -e

if [ -z "$@" ]; then
  exec bundle exec puma -C config/puma.rb ./config.ru
else
  exec "$@"
fi
