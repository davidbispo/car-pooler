#!/bin/bash
rm -f tmp/pids/server.pid
bundle exec puma -p 9091 -e production