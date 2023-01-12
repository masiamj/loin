#!/usr/bin/env bash

# exit on error
set -o errexit

# Run migrations
/app/bin/migrate

# Run the seeds
/app/bin/loin eval "Loin.Release.seed"

# Start the server
/app/bin/server