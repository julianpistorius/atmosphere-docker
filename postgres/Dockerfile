FROM postgres:9.6

# This line allows build to complete with or without db-dump.sql
COPY ./create_tropo_db.sh db-dump.sql* /docker-entrypoint-initdb.d/
