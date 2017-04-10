#!/bin/sh

#read settings
source ./my_settings.sh

docker rm -f rp1 
docker rm -f rp2 
docker rm -f rp3

docker run -d --cap-add sys_resource --name rp1 -p 8443:8443 redislabs/redis
docker run -d --cap-add sys_resource --name rp2 -p 8442:8443 redislabs/redis
docker run -d --cap-add sys_resource --name rp3 -p 8441:8443 redislabs/redis 

cmd="'sudo /opt/redislabs/bin/rladmin cluster create name $rp_fqdn username $rp_admin_account_name password $rp_admin_account_password persistent_path /datadisks/disk1 flash_enabled flash_path /mnt"