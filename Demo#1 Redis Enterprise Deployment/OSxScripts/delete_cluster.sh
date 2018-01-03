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


echo $warning_color"WARNING"$no_color": This will wipe out your cluster nodes and delete all your data on containers [y/n]"
read yes_no

if [ $yes_no == 'y' ]
then
    #remove
    echo $info_color"INFO"$no_color": Running cleanup..."

    i=0
    for ((i = 0; i<$rp_total_nodes; i++))
    do
        echo $info_color"INFO"$no_color": Deleting containers rp"$i
        docker rm -f rp$i 
    done

    echo $info_color"INFO"$no_color": Deleting containers for loadgen"$i
    docker rm -f loadgen_memtier

    echo $info_color"INFO"$no_color": Deleting network "$rp_network_name
    docker network rm $rp_network_name    
else
    echo $info_color"INFO"$no_color": Cleanup Cancelled"
fi

echo $info_color"INFO"$no_color": Done with cleanup."
