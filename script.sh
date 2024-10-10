#!/bin/sh

# Attivare l'ambiente virtuale
. venv/bin/activate

# Eseguire il server Python in background
python3 docker_backend/server.py &

# Eseguire il server HTTP
python3 -m http.server 8080 --directory build/web & google-chrome --headless --disable-gpu --remote-debugging-port=9222 http://localhost:8080

# Attendere che i processi in background finiscano (opzionale)
wait
