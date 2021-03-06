#!/bin/sh

# The MIT License (MIT)
#
# Copyright (c) 2017 Redis Labs
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Author: Cihan Biyikoglu - github:(cihanb)


#read settings
source ../settings.sh

#create network 
echo ""
echo $info_color"INFO"$no_color": Starting Redis Enterprise Pack containers on a single network"

echo ""
echo $info_color"INFO"$no_color": Creating network "$rp_network_name
docker network create --ip-range 10.0.0.0/16 --subnet=10.0.0.0/16 $rp_network_name

#create cluster
for ((i = 0; i<$rp_total_nodes; i++))
do
    if [ $i -eq 0 ]
    then 
        #first node
        echo ""
        echo $info_color"INFO"$no_color": Starting container for node#"$i
        docker run -d --cpus $rp_container_cpus -m $rp_container_ram --cap-add sys_resource --network $rp_network_name --name $rp_container_name_prefix$i -p $rp_admin_ui_port:$rp_admin_ui_port -p $rp_admin_restapi_port:$rp_admin_restapi_port -p $rp_database_port_prefix:$rp_database_port_prefix $rp_container_tag

        #wait for the container to launch and redis enterprise to start
        echo $info_color"INFO"$no_color": Waiting for containers to launch and services to start"
        sleep 30 

        #add license
		if [ $rp_license_file != "" ]
		then
			echo $info_color"INFO"$no_color": UPLOADING LICENSE FILE"
	        docker cp $rp_license_file $rp_container_name_prefix$i:/opt/rp_license.txt

            echo $info_color"INFO"$no_color": Initializing the cluster with node#"$i
            docker exec -d --privileged $rp_container_name_prefix$i "/opt/redislabs/bin/rladmin" cluster create name $rp_fqdn username $rp_admin_account_name password $rp_admin_account_password flash_enabled license_file /opt/rp_license.txt
        else
            echo $info_color"INFO"$no_color": Initializing the cluster with node#"$i
            docker exec -d --privileged $rp_container_name_prefix$i "/opt/redislabs/bin/rladmin" cluster create name $rp_fqdn username $rp_admin_account_name password $rp_admin_account_password flash_enabled 
		fi

        #get first node ip
        cmd="docker exec -it $rp_container_name_prefix$i ifconfig | grep 10.0.0. | cut -d\":\" -f 2 | cut -d\" \" -f 1"
        rp_first_node_ip=$(eval $cmd)

    else
        #added nodes
        rp_admin_ui_port_mapped=$(( $rp_admin_ui_port+$i-1 ))
        rp_admin_restapi_port_mapped=$(( $rp_admin_restapi_port+$i-1 ))

        echo ""
        echo $info_color"INFO"$no_color": Starting container for node#"$i
        docker run -d --cpus $rp_container_cpus -m $rp_container_ram --cap-add sys_resource --network $rp_network_name --name $rp_container_name_prefix$i $rp_container_tag

        
        # wait for cluster setup to finish
        sleep 30
        echo $info_color"INFO"$no_color": Joining node#"$i" to the cluster"
        docker exec -d --privileged $rp_container_name_prefix$i "/opt/redislabs/bin/rladmin" cluster join username $rp_admin_account_name password $rp_admin_account_password nodes $rp_first_node_ip flash_enabled
    fi
 done

# the following may be a good idea for general purpose testing - but they are optional
# sudo ./rladmin tune cluster default_sharded_proxy_policy all-master-shards
# sudo ./rladmin tune cluster default_shards_placement sparse

#create database
sleep 60
for ((i = 0; i<$rp_total_dbs; i++))
do
    echo $info_color"INFO"$no_color": Creating database "$rp_database_name_prefix$i" on port "$(($rp_database_port_prefix+$i))
    curl -k -u "$rp_admin_account_name:$rp_admin_account_password" --request POST --url "https://localhost:$rp_admin_restapi_port/v1/bdbs" --header 'content-type: application/json' --data '{"name":"'$rp_database_name_prefix$i'","type":"redis","memory_size":102400,"port":'$(($rp_database_port_prefix+$i))'}'
    sleep 5
done

#populate sample data
sleep 30
for ((i = 0; i<$rp_total_dbs; i++))
do
    echo $info_color"INFO"$no_color": Populating database "$rp_database_name_prefix$i" on port "$(($rp_database_port_prefix+$i))
    docker exec $rp_container_name_prefix"0" /opt/redislabs/bin/redis-cli -p $(($rp_database_port_prefix+$i)) mset k1 1 k2 2 k3 3 k4 4 k5 5
done


echo ""
echo $info_color"INFO"$no_color": "$rp_total_nodes" node Redis Enterprise Pack cluster created."
echo $info_color"INFO"$no_color": running container status:"
docker ps -a | grep $rp_container_name_prefix
echo ""
echo $info_color"INFO"$no_color": NEXT STEPS:"
echo $info_color"INFO"$no_color": Visit: https://localhost:8443 to view the database and stats."
echo $info_color"INFO"$no_color": Run: docker exec -it "$rp_container_name_prefix"1 bash to connect to first node"
