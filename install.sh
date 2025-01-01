#!/bin/bash

# Update flutter submodule
git submodule update --init --recursive

# Export PATH
export PATH="$PATH:/workspaces/flutter-test/vendor/flutter/bin"
echo 'Install completed'
