#!/bin/sh

#read settings
source ../settings.sh

#create
echo ""
echo $info_color"INFO"$no_color": Starting Redis Enterprise Pack containers on a single network"

echo ""
echo $info_color"INFO"$no_color": Creating network "$rp_network_name
docker network create --ip-range 10.0.0.0/16 --subnet=10.0.0.0/16 $rp_network_name

i=0
for ((i = 1; i<=$rp_total_nodes; i++))
do
    if [ $i -eq 1 ]
    then 
        #start admin ports from 8443 and +1 per node
        rp_admin_ui_port=8443
        
        echo ""
        echo $info_color"INFO"$no_color": Initializing the cluster with node#"$i
        docker run -d --cap-add sys_resource --network $rp_network_name --name rp$i -p $rp_admin_ui_port:8443 redislabs/redis:latest

        #wait for the container to launch and redis enterprise to start
        echo $info_color"INFO"$no_color": Waiting for containers to launch and services to start"
        sleep 30 

        echo $info_color"INFO"$no_color": Initializing the cluster with node#"$i
        docker exec -d --privileged rp$i "/opt/redislabs/bin/rladmin" cluster create name $rp_fqdn username $rp_admin_account_name password $rp_admin_account_password flash_enabled
    else
        #added nodes
        rp_admin_ui_port=$(( 8443+$i-1 ))

        echo ""
        echo $info_color"INFO"$no_color": Initializing the cluster with node#"$i
        docker run -d --cap-add sys_resource --network $rp_network_name --name rp$i -p $rp_admin_ui_port:8443 redislabs/redis:latest

        
        # wait for cluster setup to finish
        sleep 30
        echo $info_color"INFO"$no_color": Joining node#"$i" to the cluster"
        docker exec -d --privileged rp$i "/opt/redislabs/bin/rladmin" cluster join username $rp_admin_account_name password $rp_admin_account_password nodes 10.0.0.2 flash_enabled
    fi
 done

echo ""
echo $info_color"INFO"$no_color": "$rp_total_nodes" node Redis Enterprise Pack cluster created."
echo $info_color"INFO"$no_color": Visit: https://localhost:8443 and create a database."
echo $info_color"INFO"$no_color": Run: docker exec -it rp1 bash to connect to first node."
