#!/bin/bash

# Update flutter submodule
git submodule init
git submodule update

# Export PATH
export PATH="$PATH:/workspaces/flutter-test/vendor/flutter/bin"
echo 'Install completed'
