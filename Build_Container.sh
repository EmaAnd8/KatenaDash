#!/bin/sh

docker compose up --build
cd docker_backend
mkdir Blockscout
cd Blockscout
git clone "https://github.com/blockscout/blockscout.git"
cd docker-compose
docker compose up -d