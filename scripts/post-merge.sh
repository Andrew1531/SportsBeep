#!/bin/bash
set -e

cd frontend
bundle install --jobs 4 --retry 3
RAILS_ENV=development bundle exec rake db:migrate
