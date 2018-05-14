This script backs-up home directory partially and reminds me of rest.

```script
#!/bin/sh
#backup all of it.
#if using exclude={,} format make sure that there is more than one entry in the {} block
#the following will still copy any dotfiles not at the parent(right inside /lobo)
echo ""
echo "**********************************************************"
echo "Manually encrypt (Desktop, Documents, Downloads, Work)"
echo "Using Fast compression, password with filename encryption"
echo "**********************************************************"
echo ""
rsync -aAXrv --delete /home/lobo/Music/ /run/media/lobo/Lobo/ArchBackup/Music
rsync -aAXrv --delete /home/lobo/Pictures/ /run/media/lobo/Lobo/ArchBackup/Pictures
rsync -aAXrv --delete /home/lobo/Videos/ /run/media/lobo/Lobo/ArchBackup/Videos

```
