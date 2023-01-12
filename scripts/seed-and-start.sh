#!/usr/bin/env bash

# Exit on error
set -o errexit

# Run seeds
_build/prod/rel/loin/bin/loin eval "Loin.Release.seed"

# Start server
_build/prod/rel/loin/bin/loin start