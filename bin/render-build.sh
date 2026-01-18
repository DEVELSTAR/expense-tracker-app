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
# Seed the database if SEED_DATABASE is set
if [ "$SEED_DATABASE" = "true" ]; then
  echo "🌱 Seeding database..."
  bundle exec rails db:seed
else
  echo "⏩ Skipping seed (SEED_DATABASE env var not set to 'true')"
fi