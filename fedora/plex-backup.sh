#! /usr/bin/bash

sudo echo ".dump metadata_item_settings" | sudo sqlite3 "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db" | sudo grep -v TABLE | sudo grep -v INDEX > viewhistory.sql