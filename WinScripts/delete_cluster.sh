#!/bin/sh

#read settings
source ../settings.sh


echo $warning_color"WARNING"$no_color": This will wipe out your cluster nodes and delete all your data on containers [y/n]"
read yes_no

if [ $yes_no == 'y' ]
then
    #remove
    echo $info_color"INFO"$no_color": Running cleanup..."

    i=0
    for ((i = 1; i<=$rp_total_nodes; i++))
    do
        echo $info_color"INFO"$no_color": Deleting containers rp"$i
        docker rm -f rp$i 
    done

    echo $info_color"INFO"$no_color": Deleting network "$rp_network_name
    docker network rm $rp_network_name    
else
    echo $info_color"INFO"$no_color": Cleanup Cancelled"
fi

echo $info_color"INFO"$no_color": Done with cleanup."
