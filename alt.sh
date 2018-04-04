#!/bin/bash

echo "Committing containers to new images..."
docker commit atmospheredocker_atmosphere_1 alt_atmo
docker commit atmospheredocker_troposphere_1 alt_tropo
docker commit atmospheredocker_nginx_1 alt_nginx

echo "Stopping docker-compose..."
docker-compose stop

echo "Creating new volumes..."
docker volume create alt_tropo
docker volume create alt_env
docker volume create alt_sockets

echo "Copying data to new volumes..."
docker run --rm -it -v atmospheredocker_tropo:/from -v alt_tropo:/to alpine ash -c "cd /from ; cp -a . /to"
docker run --rm -it -v atmospheredocker_atmo-env:/from -v alt_env:/to alpine ash -c "cd /from ; cp -a . /to"
docker run --rm -it -v atmospheredocker_sockets:/from -v alt_sockets:/to alpine ash -c "cd /from ; cp -a . /to"
