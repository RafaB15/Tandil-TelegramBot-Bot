#!/bin/sh
set -x
ENV=development bundle exec rdbg --open -n -c -- bundle exec ruby app.rb
