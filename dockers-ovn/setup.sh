#! /bin/bash
#
# set-dockers-net.sh
# Copyright (C) 2017 zach <zacharyzjp@gmail.com>
#
# Distributed under terms of the MIT license.
#
set -o xtrace 
. ../util/cmd-encap.sh

case $1 in
    step1) echo "create docker network with openswitch driver"
        LSID=`docker network create -d openvswitch --subnet=192.168.10.0/24 --gateway=192.168.10.1 cNet`
        docker network ls 
	# add logical port on cNet(05bc454f4ff4501303e99ef2d3d14621e0d1c4c965567efb266c457d91118922)
        ovn-nbctl-cmd lsp-add $LSID c-physnet1
        ovn-nbctl-cmd lsp-set-addresses c-physnet1  unknown
        ovn-nbctl-cmd lsp-set-type c-physnet1 localnet
        ovn-nbctl-cmd lsp-set-options c-physnet1 network_name=physnet1
    ;;
    clean1)
        ovn-nbctl-cmd lsp-del c-physnet1
	    docker network rm cNet
	    docker network ls 
    ;;

    step2) echo "build up 2 dockers within containers network(cNet), driver is openswitch"
        docker run -itd --rm --net=cNet busybox
        docker run -itd --rm --net=cNet busybox
	    docker ps -a 
    ;;

    clean2)
	    docker stop $(docker ps -a -q) 
    ;;

    step3) echo "setup logical port on cNet via physnet1 to connect local port"
        sudo ovs-vsctl set-controller br-int tcp:10.11.59.179:6653
        #set ovn-bridge-mapping on eacho physical chassise	
        sudo ovs-vsctl add-br br-dut
        sudo ovs-vsctl set open .  external-ids:ovn-bridge-mappings=physnet1:br-dut
        sudo ovs-vsctl set-controller br-dut tcp:10.11.59.179:6653

    ;;

    clean3)
        sudo ovs-vsctl del-br br-dut
        sudo ovs-vsctl remove open .  external-ids ovn-bridge-mappings
    ;;

    step4) echo "Add physical interface 'enp13s2' into br-dut to connect real physical network"
	    sudo ovs-vsctl add-port  br-dut enp13s2 
    ;;

    clean4)
	    sudo ovs-vsctl del-port br-dut  enp13s2 
    ;;

esac

