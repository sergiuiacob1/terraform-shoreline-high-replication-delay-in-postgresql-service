
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# High replication delay in PostgreSQL service
---

This incident type refers to a high replication delay in a PostgreSQL service. Replication delay is the time it takes for a change made in the primary database to be replicated to the standby database. When the delay is abnormally high, it can indicate a problem with the replication process or the database itself. This can lead to data inconsistencies and other issues that can impact the performance and availability of the service. The incident usually requires investigation and troubleshooting to identify the root cause of the delay and to implement a solution to resolve the issue.

### Parameters
```shell
# Environment Variables

export HOST="PLACEHOLDER"

export USERNAME="PLACEHOLDER"

export DATABASE="PLACEHOLDER"

export STANDBY_SERVER="PLACEHOLDER"

```

## Debug

### Connect to the database server and run psql command
```shell
psql -h ${HOST} -U ${USERNAME} -d ${DATABASE}
```

### Check the replication status on the master
```shell
SELECT * FROM pg_stat_replication;
```

### Check the replication status on the standby
```shell
SELECT * FROM pg_stat_wal_receiver;
```

### Check the replication lag time on the standby
```shell
SELECT now() - pg_last_xact_replay_timestamp() AS replication_lag_time;
```

### Check the PostgreSQL logs for any errors related to replication
```shell
cat /var/lib/pgsql/logs/*.log | grep "replication"
```

### Check the PostgreSQL configuration file for any replication-related settings
```shell
cat /var/lib/pgsql/conf/postgresql.conf | grep "replication"
```

## Repair

### Restart the PostgreSQL service
```shell
sudo systemctl restart postgresql.service
```
### Restart the replication process by resetting the standby server to the latest checkpoint on the primary server. This can be done by stopping the standby server, removing all files in the PostgreSQL data directory, and starting the server again.
```shell
#!/bin/bash

# Stop the standby server

sudo systemctl stop ${STANDBY_SERVER}

# Remove all files in the PostgreSQL data directory

sudo rm -rf /var/lib/pgsql/data/*

# Start the standby server

sudo systemctl start ${STANDBY_SERVER}

```

### Verify that the standby server is up to date with the primary server by checking the WAL files on the standby server. If there are any discrepancies, restore the missing files from the primary server.
```shell

#!/bin/bash

# Check the WAL files on the standby server

standby_wal_files=`ssh $standby_server ls -1 /path/to/wal/files`

primary_wal_files=`ssh $primary_server ls -1 /path/to/wal/files`

# Find the missing WAL files on the standby server

missing_wal_files=`diff <(echo "$standby_wal_files") <(echo "$primary_wal_files") | grep "<" | sed 's/< //'`

if [ -n "$missing_wal_files" ]

then

  # Restore the missing WAL files from the primary server

  for file in $missing_wal_files

  do

    scp $primary_server:/path/to/wal/files/$file $standby_server:/path/to/wal/files/

  done

fi
echo "WAL files on standby server are up to date with primary server."

```