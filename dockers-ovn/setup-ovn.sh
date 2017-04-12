#! /bin/bash
#
# set-dockers-net.sh
# Copyright (C) 2017 zach <zacharyzjp@gmail.com>
#
# Distributed under terms of the MIT license.
#
set -o xtrace 
. ../util/cmd-encap.sh
if [ $# -lt 2 ]; then 
    cat <<EOF
    $0 <ovs physnet name> <logical switch name> [subnet] [endpoint count] [docker image]
    -subnet: default is 192.168.10.0/24
    -endpoint num: default 2
    -docker image: default busybox:latest
EOF
    exit 1
fi

PHYNET=$1
LSW=$2
SUBNET=192.168.10.0/24
COUNT=2
IMAGE=busybox:latest

[ -n "$3" ] && SUBNET=$3
[ -n "$4" ] && COUNT=$4
[ -n "$5" ] && IMAGE=$5


echo "docker network network within openswitch driver"
LSID=`docker network create -d openvswitch --subnet=$SUBNET $LSW`
docker network ls 

echo "add localnet port in container network"
ovn-nbctl-cmd lsp-add $LSID $LSW-2physnet
ovn-nbctl-cmd lsp-set-addresses $LSW-2physnet  unknown
ovn-nbctl-cmd lsp-set-type $LSW-2physnet localnet
ovn-nbctl-cmd lsp-set-options $LSW-2physnet network_name=$PHYNET

for ((c=1; c<=$COUNT; c++))
do 
    docker run -itd --rm --net=$LSW $IMAGE
done
docker ps -a 
    
#ovn-nbctl-cmd lsp-del lsp-2physnet
#docker network rm cNet
#docker network ls 
#
#docker stop $(docker ps -a -q) 
