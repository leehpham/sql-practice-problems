#!/bin/bash

# Copy the backup file into the container in the /var/opt/mssql/backup directory.
docker cp ./db-backups/Northwind2016.bak mssql:/var/opt/mssql/backup

# Run sqlcmd inside the container to list out logical file names and paths inside the backup.
docker exec -it mssql /opt/mssql-tools18/bin/sqlcmd \
  -S localhost \
  -U SA \
  -P 'admin@1234' \
  -C \
  -Q 'RESTORE FILELISTONLY FROM DISK = "/var/opt/mssql/backup/Northwind2016.bak"' \
  | tr -s ' ' | cut -d ' ' -f 1-2

# Call the RESTORE DATABASE command to restore the database inside the container.
docker exec -it mssql /opt/mssql-tools18/bin/sqlcmd \
  -S localhost \
  -U SA \
  -P 'admin@1234' \
  -C \
  -Q 'RESTORE DATABASE Northwind2016 FROM DISK = "/var/opt/mssql/backup/Northwind2016.bak" WITH MOVE "Northwind" TO "/var/opt/mssql/data/Northwind2016.mdf", MOVE "Northwind_log" TO "/var/opt/mssql/data/Northwind2016.ldf"'