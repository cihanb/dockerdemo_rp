#!/bin/sh

#read settings
source ../settings.sh


echo "WARNING: This will wipe out your cluster nodes and delete all your data on containers [y/n]"
read yes_no

if [ $yes_no == 'y' ]
then
    #remove
    echo "INFO: Running cleanup..."

    i=0
    for ((i = 1; i<=$rp_total_nodes; i++))
    do
        echo "INFO: Deleting containers rp"$i
        docker rm -f rp$i 
    done

    echo "INFO: Deleting network "$rp_network_name
    docker network rm $rp_network_name    
else
    echo "INFO: Cleanup Cancelled"
fi

echo "INFO: Done with cleanup."
