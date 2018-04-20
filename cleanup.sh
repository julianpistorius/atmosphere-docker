#!/bin/bash

PWD_CMD=`which pwd`
PWD=`$PWD_CMD`
RM_CMD=`which rm`

if [[ $1 == "--prune" ]]
then
  echo "Removing volumes..."
  docker volume rm \
  atmospheredocker_atmo-env \
  atmospheredocker_sockets \
  atmospheredocker_tropo
else
  echo "Removing atmo-local from build directories..."
  $RM_CMD -rf $PWD/nginx/atmo-local
  $RM_CMD -rf $PWD/atmosphere/atmo-local
  $RM_CMD -rf $PWD/troposphere/atmo-local
  $RM_CMD -rf $PWD/postgres/atmo-local

  echo "Removing logs..."
  $RM_CMD -rf $PWD/logs/*
fi
