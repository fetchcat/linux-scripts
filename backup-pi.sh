# Backup Home to Pi (Exclude cache, Downloads, all NodeModules)
rsync -aAXv --delete --exclude={"/home/michelle/.cache","/home/michelle/Downloads","*/node_modules"} -e ssh /home michelle@pi.local:/Elements/Backups/Meshified/Meshified-A

# Backup Media to Pi (Exclude drive Trash)
rsync -aAXv --exclude={".Trash-1000"} -e ssh /MediaDrive michelle@pi.local:/Elements/Backups
