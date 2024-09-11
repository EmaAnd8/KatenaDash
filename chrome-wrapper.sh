#!/bin/bash
# chrome-wrapper.sh
# This script wraps the Google Chrome command to include the --no-sandbox flag

/usr/bin/google-chrome-stable --no-sandbox "$@"
