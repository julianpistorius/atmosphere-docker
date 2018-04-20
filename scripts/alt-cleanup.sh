#!/bin/bash

echo "Killing and deleting alternate containers..."
docker kill atmospheredocker_nginx-alt_1 atmospheredocker_troposphere-alt_1 atmospheredocker_atmosphere-alt_1 atmospheredocker_postgres-alt_1
docker rm atmospheredocker_nginx-alt_1 atmospheredocker_troposphere-alt_1 atmospheredocker_atmosphere-alt_1 atmospheredocker_postgres-alt_1

echo "Deleting alternate volumes..."
docker volume rm alt_env alt_sockets alt_tropo

echo "Deleting alternate images"
docker rmi alt_atmo alt_tropo alt_nginx alt_postgres
