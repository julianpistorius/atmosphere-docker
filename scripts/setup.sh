#!/bin/bash

PWD_CMD=`which pwd`
PWD=`$PWD_CMD`
CP_CMD=`which cp`
RM_CMD=`which rm`

echo "Copying atmo-local to ./nginx..."
$CP_CMD -R $PWD/atmo-local $PWD/nginx/
$RM_CMD -f $PWD/nginx/atmo-local/*.sql

echo "Copying atmo-local to ./atmosphere..."
$CP_CMD -R $PWD/atmo-local $PWD/atmosphere/
$RM_CMD -f $PWD/atmosphere/atmo-local/*.sql

echo "Copying atmo-local to ./troposphere..."
$CP_CMD -R $PWD/atmo-local $PWD/troposphere/
$RM_CMD -f $PWD/troposphere/atmo-local/*.sql

echo "Copying atmo-local to ./postgres..."
$CP_CMD -R $PWD/atmo-local $PWD/postgres/
$RM_CMD -rf $PWD/postgres/atmo-local/clank_init
