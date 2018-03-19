#!/bin/bash

PWD_CMD=`which pwd`
PWD=`$PWD_CMD`
CP_CMD=`which cp`

$CP_CMD -R $PWD/atmo-local $PWD/nginx/
$CP_CMD -R $PWD/atmo-local $PWD/atmosphere/
$CP_CMD -R $PWD/atmo-local $PWD/troposphere/
