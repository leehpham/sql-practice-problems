#!/bin/bash

# Restore a MS SQL Server database from a bak file in a Linux container.

# The content of this script is based on:
# https://learn.microsoft.com/en-us/sql/linux/tutorial-restore-backup-in-sql-server-container?view=sql-server-ver16&tabs=cli

# Pull the SQL Server 2022 (16.x) Linux container image from the Microsoft Container Registry.
docker pull mcr.microsoft.com/mssql/server:2022-latest

# Run the container image (create a SQL Server container)
# docker run: run a command in a new container.
# --name: assign a name to the container. Is there a way to rename a container after it's been created?
# -p: publish a container's port(s) to the host. <host_port:container_port>.
# -e '<key=value>': set environment variables.
# -d, --detach: Run container in background and print container ID.
# -v, --volume: Bind mount a volume. (We don't need this for now).
# -v sql1data:/var/opt/mssql \
docker run \
  --name 'mssql_all_purposes' \
  -p 1401:1433 \
  -e 'ACCEPT_EULA=Y' \
  -e 'MSSQL_SA_PASSWORD=admin@12345' \
  -d \
  mcr.microsoft.com/mssql/server:2022-latest

# Change the SA (system admin) password through a Transact-SQL statement.
# Run echo $MSSQL_SA_PASSWORD to get the current password.
# For sqlcmd,
# -S means server
# -U means user
# -P means password
# -C means to trust server certificate.
# -Q means query
docker exec \
  -it mssql_all_purposes /opt/mssql-tools18/bin/sqlcmd \
  -S localhost \
  -U SA \
  -P 'admin@12345' \
  -C \
  -Q 'ALTER LOGIN SA WITH PASSWORD="admin@1234"'

# Create a backup folder
docker exec -it mssql_all_purposes mkdir /var/opt/mssql/backup

# Copy the backup file into the container in the /var/opt/mssql/backup directory.
docker cp ./db-backups/Northwind2016.bak mssql_all_purposes:/var/opt/mssql/backup

# Run sqlcmd inside the container to list out logical file names and paths inside the backup.
docker exec -it mssql_all_purposes /opt/mssql-tools18/bin/sqlcmd \
  -S localhost \
  -U SA \
  -P 'admin@1234' \
  -C \
  -Q 'RESTORE FILELISTONLY FROM DISK = "/var/opt/mssql/backup/Northwind2016.bak"' \
  | tr -s ' ' | cut -d ' ' -f 1-2

# Call the RESTORE DATABASE command to restore the database inside the container.
docker exec -it mssql_all_purposes /opt/mssql-tools18/bin/sqlcmd \
  -S localhost \
  -U SA \
  -P 'admin@1234' \
  -C \
  -Q 'RESTORE DATABASE Northwind2016 FROM DISK = "/var/opt/mssql/backup/Northwind2016.bak" WITH MOVE "Northwind" TO "/var/opt/mssql/data/Northwind2016.mdf", MOVE "Northwind_log" TO "/var/opt/mssql/data/Northwind2016.ldf"'