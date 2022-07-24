#!/bin/bash
rm -f tmp/pids/server.pid
bundle exec puma -p $PORT -e $RAILS_ENV