#!/bin/bash

echo "Importing seed data for a great development experience :)"

/usr/local/bin/pg_restore -O --dbname $POSTGRES_DB --username $POSTGRES_USER /docker-entrypoint-initdb.d/dev-seed.dump

echo "Seed data importing finished."
