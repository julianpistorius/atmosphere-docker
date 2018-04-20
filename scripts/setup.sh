#!/bin/bash

PWD_CMD=`which pwd`
PWD=`$PWD_CMD`
CP_CMD=`which cp`

echo "Copying atmo-local to ./nginx..."
$CP_CMD -R $PWD/atmo-local $PWD/nginx/

echo "Copying atmo-local to ./atmosphere..."
$CP_CMD -R $PWD/atmo-local $PWD/atmosphere/

echo "Copying atmo-local to ./troposphere..."
$CP_CMD -R $PWD/atmo-local $PWD/troposphere/

echo "Copying atmo-local to ./postgres..."
$CP_CMD -R $PWD/atmo-local $PWD/postgres/
