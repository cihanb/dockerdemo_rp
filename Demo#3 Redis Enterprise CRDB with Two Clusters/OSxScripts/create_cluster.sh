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

#create
echo ""
echo $info_color"INFO"$no_color": Starting Redis Enterprise Pack - Two Cluster with a CRDB for Active-Active Geo-Distribution"

echo ""
echo $info_color"INFO"$no_color": Creating network "$rp_network_name
docker network create --ip-range 10.0.0.0/16 --subnet=10.0.0.0/16 $rp_network_name

i=0
for ((i = 1; i<=$rp1_total_nodes; i++))
do
    if [ $i -eq 1 ]
    then 
        
        echo ""
        echo $info_color"INFO"$no_color": Starting container for node#"$i
        docker run -d --cpus $rp_container_cpus -m $rp_container_ram --cap-add sys_resource -h $rp1_container_name_prefix$i --network $rp_network_name --name $rp1_container_name_prefix$i -p $rp1_admin_ui_port:$rp_admin_ui_port -p $rp1_admin_restapi_port:$rp_admin_restapi_port -p $rp1_database_port:$rp_database_port -p 8080:8080 $rp_container_tag

        #wait for the container to launch and redis enterprise to start
        echo $info_color"INFO"$no_color": Waiting for containers to launch and services to start"
        sleep 30 

        echo $info_color"INFO"$no_color": Initializing the cluster with node#"$i
        docker exec -d --privileged $rp1_container_name_prefix$i "/opt/redislabs/bin/rladmin" cluster create name $rp1_fqdn username $rp_admin_account_name password $rp_admin_account_password flash_enabled

        cmd="docker exec -it $rp1_container_name_prefix$i ifconfig | grep 10.0.0. | cut -d\":\" -f 2 | cut -d\" \" -f 1"
        rp1_first_node_ip=$(eval $cmd)
    else
        #added nodes
        rp_admin_ui_port_mapped=$(( $rp_admin_ui_port+$i-1 ))
        rp_admin_restapi_port_mapped=$(( $rp_admin_restapi_port+$i-1 ))

        echo ""
        echo $info_color"INFO"$no_color": Starting container for node#"$i
        docker run -d --cpus $rp_container_cpus -m $rp_container_ram --cap-add sys_resource -h $rp1_container_name_prefix$i.$rp1_fqdn --network $rp_network_name --name $rp1_container_name_prefix$i -p $rp1_admin_ui_port_mapped:$rp_admin_ui_port -p $rp1_admin_restapi_port_mapped:$rp_admin_restapi_port $rp_container_tag

        
        # wait for cluster setup to finish
        sleep 30
        echo $info_color"INFO"$no_color": Joining node#"$i" to the cluster"
        docker exec -d --privileged $rp1_container_name_prefix$i "/opt/redislabs/bin/rladmin" cluster join username $rp_admin_account_name password $rp_admin_account_password nodes $rp1_first_node_ip flash_enabled
    fi
 done

i=0
for ((i = 1; i<=$rp2_total_nodes; i++))
do
    if [ $i -eq 1 ]
    then 
        
        echo ""
        echo $info_color"INFO"$no_color": Starting container for node#"$i
        docker run -d --cpus $rp_container_cpus -m $rp_container_ram --cap-add sys_resource -h $rp1_container_name_prefix$i --network $rp_network_name --name $rp2_container_name_prefix$i -p $rp2_admin_ui_port:$rp_admin_ui_port -p $rp2_admin_restapi_port:$rp_admin_restapi_port -p $rp2_database_port:$rp_database_port $rp_container_tag

        #wait for the container to launch and redis enterprise to start
        echo $info_color"INFO"$no_color": Waiting for containers to launch and services to start"
        sleep 30 

        echo $info_color"INFO"$no_color": Initializing the cluster with node#"$i
        docker exec -d --privileged $rp2_container_name_prefix$i "/opt/redislabs/bin/rladmin" cluster create name $rp2_fqdn username $rp_admin_account_name password $rp_admin_account_password flash_enabled

        cmd="docker exec -it $rp2_container_name_prefix$i ifconfig | grep 10.0.0. | cut -d\":\" -f 2 | cut -d\" \" -f 1"
        rp2_first_node_ip=$(eval $cmd)  
    else
        #added nodes
        rp_admin_ui_port_mapped=$(( $rp_admin_ui_port+$i-1 ))
        rp_admin_restapi_port_mapped=$(( $rp_admin_restapi_port+$i-1 ))

        echo ""
        echo $info_color"INFO"$no_color": Starting container for node#"$i
        docker run -d --cpus $rp_container_cpus -m $rp_container_ram --cap-add sys_resource -h $rp1_container_name_prefix$i --network $rp_network_name --name $rp2_container_name_prefix$i -p $rp2_admin_ui_port_mapped:$rp_admin_ui_port -p $rp2_admin_restapi_port_mapped:$rp_admin_restapi_port $rp_container_tag

        
        # wait for cluster setup to finish
        sleep 30
        echo $info_color"INFO"$no_color": Joining node#"$i" to the cluster"
        docker exec -d --privileged $rp2_container_name_prefix$i "/opt/redislabs/bin/rladmin" cluster join username $rp_admin_account_name password $rp_admin_account_password nodes $rp2_first_node_ip flash_enabled
    fi
 done


# the following may be a good idea for general purpose testing - but they are optional
# sudo ./rladmin tune cluster default_sharded_proxy_policy all-master-shards
# sudo ./rladmin tune cluster default_shards_placement sparse

#create database
sleep 30
echo ""
echo $info_color"INFO"$no_color": Creating database sample-crdb on port 12000"
# json_dboptions='{"default_db_config": {"name": "sample-crdb", "bigstore": false, "data_persistence": "disabled", "replication": true, "memory_size": 1024000, "shards_count": 1, "port": 12000}, "instances": [{"cluster": {"url": "http://'$rp1_fqdn':8080", "credentials": {"username": "'$rp_admin_account_name'", "password": "'$rp_admin_account_password'"}, "name": "'$rp1_fqdn'"}, "compression": 6}, {"cluster": {"url": "http://'$rp2_fqdn':8080", "credentials": {"username": "'$rp_admin_account_name'", "password": "'$rp_admin_account_password'"}, "name": "'$rp2_fqdn'"}, "compression": 6}], "name": "sample-crdb"}'
# curl -k -u "$rp_admin_account_name:$rp_admin_account_password" --request POST --url "http://localhost:8080/v1/crdbs" --header 'content-type: application/json' --data "$json_dboptions"
curl -k -u "$rp_admin_account_name:$rp_admin_account_password" -H "Content-Type: application/json" -X POST -d '{"default_db_config": {"name": "sample-crdb", "bigstore": false, "data_persistence": "aof", "replication": false, "memory_size": 1024000, "aof_policy": "appendfsync-every-sec", "snapshot_policy": [], "shards_count": 2, "shard_key_regex": [{"regex": ".*{(?<tag>.*)}.*"}, {"regex": "(?<tag>.*)"}], "port": 12000}, "instances": [{"cluster": {"url": "http://'$rp1_fqdn':8080", "credentials": {"username": "'$rp_admin_account_name'", "password": "'$rp_admin_account_password'"}, "name": "'$rp1_fqdn'"}, "compression": 6}, {"cluster": {"url": "http://'$rp2_fqdn':8080", "credentials": {"username": "'$rp_admin_account_name'", "password": "'$rp_admin_account_password'"}, "name": "'$rp2_fqdn'"}, "compression": 6}], "name": "sample-crdb"}' http://localhost:8080/v1/crdbs

echo ""
echo $info_color"INFO"$no_color": "$rp_total_nodes" node Redis Enterprise Pack clusters created."
echo $info_color"INFO"$no_color": running container status:"
docker ps -a | grep '$rp1_container_name_prefix\|$rp2_container_name_prefix'
echo ""
echo $info_color"INFO"$no_color": NEXT STEPS:"
echo $info_color"INFO"$no_color": Visit: https://localhost:8443 to view the database and stats on the first cluster."
echo $info_color"INFO"$no_color": Run: docker exec -it "$rp1_container_name_prefix"1 bash to connect to first node of the first cluster"
