#!/bin/sh

#read settings
source ./my_settings.sh


echo $warning_color"WARNING"$no_color": This will wipe out your cluster nodes and delete all your data on containers [y/n]"
read yes_no

if [ $yes_no == 'y' ]
then
    #remove
    echo $info_color"INFO"$no_color": Running cleanup..."

    docker rm -f rp1 
    docker rm -f rp2 
    docker rm -f rp3
    docker network rm redis_net

    #create
    echo ""
    echo $info_color"INFO"$no_color": Starting Redis Enterprise Pack containers on a single network"

    docker network create --ip-range 10.0.0.0/16 --subnet=10.0.0.0/16 redis_net
    docker run -d --cap-add sys_resource --network redis_net --name rp1 -p 8443:8443 redislabs/redis
    docker run -d --cap-add sys_resource --network redis_net --name rp2 -p 8442:8443 redislabs/redis
    docker run -d --cap-add sys_resource --network redis_net --name rp3 -p 8441:8443 redislabs/redis 

    #wait for the container to launch and redis enterprise to start
    echo ""
    echo $info_color"INFO"$no_color": Waiting for containers to launch and services to start"
    sleep 30 

    # #node1 - create cluster
    echo ""
    echo $info_color"INFO"$no_color": Initializing the cluster with node#1"
    docker exec -d --privileged rp1 "/opt/redislabs/bin/rladmin" cluster create name $rp_fqdn username cihan@redislabs.com password redislabs123 flash_enabled

    # wait for cluster setup to finish
    sleep 10
    echo ""
    echo $info_color"INFO"$no_color": Joining node#2 to the cluster"
    docker exec -d --privileged rp2 "/opt/redislabs/bin/rladmin" cluster join username cihan@redislabs.com password redislabs123 nodes 10.0.0.2 flash_enabled

    # wait for cluster setup to finish
    sleep 10
    echo ""
    echo $info_color"INFO"$no_color": Joining node#3 to the cluster"
    docker exec -d --privileged rp3 "/opt/redislabs/bin/rladmin" cluster join username cihan@redislabs.com password redislabs123 nodes 10.0.0.2 flash_enabled

else
    echo $info_color"INFO"$no_color": Cleanup Cancelled"
fi