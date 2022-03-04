#! /bin/bash

# Backup Home
rsync -aAXv --delete --exclude={"/home/michelle/.cache","/home/michelle/Downloads","*/node_modules"} /home /Elements/Backups/Meshified/Meshified-A

#Backup MediaDrive
rsync -aAXv /MediaDrive /Elements/Backups

