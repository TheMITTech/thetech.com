FROM postgres:9-alpine

COPY docker/db/dev-seed.dump /docker-entrypoint-initdb.d/
COPY docker/db/import-dev-seed.sh /docker-entrypoint-initdb.d/
