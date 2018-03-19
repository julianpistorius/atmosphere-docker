#!/bin/bash

PWD_CMD=`which pwd`
PWD=`$PWD_CMD`
RM_CMD=`which rm`

if [[ $1 == "--prune" ]]
then
  echo "Removing containers..."
  docker container rm \
  atmospheredocker_nginx_1 \
  atmospheredocker_troposphere_1 \
  atmospheredocker_atmosphere_1

  echo ""
  echo "Removing volumes..."
  docker volume rm \
  atmospheredocker_atmo-env \
  atmospheredocker_sockets \
  atmospheredocker_tropo
else
  $RM_CMD -rf $PWD/nginx/atmo-local
  $RM_CMD -rf $PWD/atmosphere/atmo-local
  $RM_CMD -rf $PWD/troposphere/atmo-local
  $RM_CMD -rf $PWD/logs/*
fi
