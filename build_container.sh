#!/bin/sh

docker compose up --build -d
cd docker_backend
rm -rf Blockscout
mkdir Blockscout
cd Blockscout
git clone "https://github.com/blockscout/blockscout.git"
cd blockscout/docker-compose
docker compose up -d
