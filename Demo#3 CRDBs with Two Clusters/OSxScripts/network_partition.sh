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
# Author: Cihan Biyikoglu - github:(cihanb) with contributions from Jake Angerman

#read settings
source ../settings.sh


echo ""
echo $info_color"INFO"$no_color": Starting Network Split Between Two Cluster with a CRDB"

#for each node in cluster1 add IPtable blocking rules to each node of cluster2 nodes
i=0
for ((i = 1; i<=$rp1_total_nodes; i++))
do
    cmd="docker exec -it $rp1_container_name_prefix$i ifconfig | grep 10.0.0. | cut -d\":\" -f 2 | cut -d\" \" -f 1"
    rp1_node_ip=$(eval $cmd)

    j=0
    for ((j = 1; j<=$rp2_total_nodes; j++))
    do
        docker exec --privileged $rp2_container_name_prefix$j iptables -A INPUT --source $rp1_node_ip -j DROP
        docker exec --privileged $rp2_container_name_prefix$j iptables -A OUTPUT --dst   $rp1_node_ip -j DROP

    done
done

