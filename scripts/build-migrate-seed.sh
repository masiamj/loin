#!/usr/bin/env bash

# Exit on error
set -o errexit

# Set up Elixir deps
mix deps.get --only prod
MIX_ENV=prod mix compile

# Set up Node deps
npm install --prefix ./assets
MIX_ENV=prod mix assets.deploy

# Build the release and overwrite the existing release directory
MIX_ENV=prod mix release --overwrite

# Run migrations
_build/prod/rel/loin/bin/loin eval "Loin.Release.migrate"

# Run seeds
_build/prod/rel/loin/bin/loin eval "Loin.Release.seed"