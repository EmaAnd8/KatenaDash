#!/bin/bash
google-chrome-stable --no-sandbox --disable-gpu --headless --remote-debugging-port=9222 "$@"
