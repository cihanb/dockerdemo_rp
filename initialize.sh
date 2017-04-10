#!/bin/sh

#read settings
source ./my_settings.sh

#remove
docker rm -f rp1 
docker rm -f rp2 
docker rm -f rp3
docker network rm redis_net

#create
docker network create redis_net
docker run -d --cap-add sys_resource --network redis_net --name rp1 -p 8443:8443 redislabs/redis
docker run -d --cap-add sys_resource --network redis_net --name rp2 -p 8442:8443 redislabs/redis
docker run -d --cap-add sys_resource --network redis_net --name rp3 -p 8441:8443 redislabs/redis 

cmd="ssh -p $i $rp_vm_admin_account_name@$service_name.cloudapp.net -i $vm_auth_cert_private -o StrictHostKeyChecking=no 'ifconfig | grep 10.0.0. | cut -d\":\" -f 2 | cut -d\" \" -f 1'"
echo $info_color"INFO"$no_color": RUNNING COMMAND: "$cmd
first_node_ip=$(eval $cmd)         

cmd="docker exec -it --privileged rp1 'sudo /opt/redislabs/bin/rladmin' cluster create name $rp_fqdn username $rp_admin_account_name password $rp_admin_account_password flash_enabled"
#add license file is not there
if [ $rp_license_file != "" ]
then
    cmd="$cmd license_file $rp_license_file"
else
    cmd="$cmd"
fi

#run the cms
eval $cmd

cmd="docker exec -it --privileged rp2 'sudo /opt/redislabs/bin/rladmin' cluster join username $rp_admin_account_name password $rp_admin_account_password nodes $first_node_ip flash_enabled"
			