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
        
        echo ""
        echo $info_color"INFO"$no_color": Starting container for node#"$i
        docker run -d --cpus $rp_container_cpus -m $rp_container_ram --cap-add sys_resource --network $rp_network_name --name $rp_container_name_prefix$i -p $rp_admin_ui_port:$rp_admin_ui_port -p $rp_admin_restapi_port:$rp_admin_restapi_port redislabs/redis:latest

        #wait for the container to launch and redis enterprise to start
        echo $info_color"INFO"$no_color": Waiting for containers to launch and services to start"
        sleep 30 

        echo $info_color"INFO"$no_color": Initializing the cluster with node#"$i
        docker exec -d --privileged $rp_container_name_prefix$i "/opt/redislabs/bin/rladmin" cluster create name $rp_fqdn username $rp_admin_account_name password $rp_admin_account_password flash_enabled
    else
        #added nodes
        rp_admin_ui_port_mapped=$(( $rp_admin_ui_port+$i-1 ))
        rp_admin_restapi_port_mapped=$(( $rp_admin_restapi_port+$i-1 ))

        echo ""
        echo $info_color"INFO"$no_color": Starting container for node#"$i
        docker run -d --cpus $rp_container_cpus -m $rp_container_ram --cap-add sys_resource --network $rp_network_name --name $rp_container_name_prefix$i -p $rp_admin_ui_port_mapped:$rp_admin_ui_port -p $rp_admin_restapi_port_mapped:$rp_admin_restapi_port redislabs/redis:latest

        
        # wait for cluster setup to finish
        sleep 30
        echo $info_color"INFO"$no_color": Joining node#"$i" to the cluster"
        docker exec -d --privileged $rp_container_name_prefix$i "/opt/redislabs/bin/rladmin" cluster join username $rp_admin_account_name password $rp_admin_account_password nodes 10.0.0.2 flash_enabled
    fi
 done

echo ""
echo $info_color"INFO"$no_color": "$rp_total_nodes" node Redis Enterprise Pack cluster created."
echo $info_color"INFO"$no_color": running container status:"
docker ps -a | grep $rp_container_name_prefix
echo ""
echo $info_color"INFO"$no_color": NEXT STEPS:"
echo $info_color"INFO"$no_color": Visit: https://localhost:8443 and create a database."
echo $info_color"INFO"$no_color": Run: docker exec -it $rp_container_name_prefix1 bash to connect to first node."
