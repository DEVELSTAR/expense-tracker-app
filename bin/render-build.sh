#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
bundle install

# Build Tailwind CSS for production
bundle exec rails tailwindcss:build

# Precompile assets
bundle exec rails assets:precompile

# Clean up old assets
bundle exec rails assets:clean

# Run database migrations
bundle exec rails db:migrate

# Optionally seed the database on first deploy
# Uncomment the following lines if you want to seed on deploy:
# if [ "$RENDER_EXTERNAL_URL" ]; then
#   bundle exec rails db:seed
# fi
