#!/bin/sh

# The MIT License (MIT)
#
# Copyright (c) 2015 Redis Labs
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
# Script Name: settings.sh
# Author: Cihan Biyikoglu - github:(cihanb)

##rp settings
rp_container_tag="redislabs/redis:5.0.1-22-beta"
#total number of nodes to set up
rp_total_nodes=1
#container ame prefix - each node get a number added based on nodecount
rp_container_name_prefix="rp"
#container resources
rp_container_ram="6GB"
rp_container_cpus=2
#license file
rp_license_file="/Users/cihan/rp_license.txt"
#cluster name
rp_fqdn="redis_net"
#TODO: change this username
rp_admin_account_name="cihan@redislabs.com"
#TODO: change this password
rp_admin_account_password="redislabs123"
#docker network name for the cluster
rp_network_name="redis_net"
#start admin UI and rest API ports from 8443 and 9443 and +1 per node
rp_admin_ui_port=8443
rp_admin_restapi_port=9443
#database config
rp_total_dbs=1
rp_database_port_prefix=12000
rp_database_name_prefix="db"



#misc settings
#enable fast delete will supress confirmation on deletes of each VM. do this only if you are certain delete will not harm your existing VMs and you have tried the script multiple times.
enable_fast_delete=0
#enable fast restart will supress confirmation on restarts of each VM. do this only if you are certain restart will not harm your existing VMs and you have tried the script multiple times.
enable_fast_restart=0
#enable fast start will supress confirmation on start of each VM. do this only if you are certain start will not harm your existing VMs and you have tried the script multiple times.
enable_fast_start=0
#enable fast shutdown will supress confirmation on shutdowns of each VM. do this only if you are certain shutdown will not harm your existing VMs and you have tried the script multiple times.
enable_fast_shutdown=0

#print colors
info_color="\033[1;32m"
warning_color="\033[0;33m"
error_color="\033[0;31m"
no_color="\033[0m"