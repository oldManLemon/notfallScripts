# DHCP Backup Collector
In case of failure it would be nice to have backups of the DHCP configuration. This script collects two types. DHCP backup and the Export of the server in an xml file. 

The backup files are stored in individual server names. 

## Usage
Run the script. The script is designed to be run every 10 minutes or another chosen increment automatically. So it is always up to date. 

## Restore
To restore find the folder with appropriate name, move the files into `C:Windows\system32\dhcp\backup` as they are. 

    -Server.domain.de
        --new
        --DhcpCfg
Only upload the contents. [Further instructions](https://activedirectorypro.com/backup-restore-windows-dhcp-server/)


