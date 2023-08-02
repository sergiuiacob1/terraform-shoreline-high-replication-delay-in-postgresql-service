#!/bin/bash

# Stop the standby server

sudo systemctl stop ${STANDBY_SERVER}

# Remove all files in the PostgreSQL data directory

sudo rm -rf /var/lib/pgsql/data/*

# Start the standby server

sudo systemctl start ${STANDBY_SERVER}