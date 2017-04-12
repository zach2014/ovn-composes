#! /bin/sh
#
# setup-ovs.sh
# Copyright (C) 2017 zach <zacharyzjp@gmail.com>
#
# Distributed under terms of the MIT license.
#


set -o xtrace 


case $1 in 
    step1) echo "centralize ovs, add required ovs network "
        . ../util/centralize-ovs.sh
        sudo ovs-vsctl set-controller br-int tcp:$OF_MGMT_IP:6653

    ;;

    clean1)
        # clean
        sudo ovs-vsctl set-controller br-int
        sudo ovs-vsctl show
        sudo ovs-vsctl list open .
    ;;

    step2) echo "Add physical interface into br-dut to connect devices in physical network"
        # add ovn-bridge-mapping for physnet1
        # br-dut to connect local network
        if [ -z "$2" ] ; then 
            echo "No given physical interface name to add"
            exit 1
        fi
        sudo ovs-vsctl add-br br-dut
        mappings="physnet1:br-dut"
        old=`sudo ovs-vsctl get open .  external-ids:ovn-bridge-mappings`
        [ -n "$old"] & mappings="$mappings,$old"
        sudo ovs-vsctl set open .  external-ids:ovn-bridge-mappings=$mappings
        sudo ovs-vsctl set-controller br-dut tcp:$OF_MGMT_IP:6653

        sudo ovs-vsctl add-port  br-dut $2 
	    ;;

    clean2)
        if [ -z "$2" ] ; then 
            echo "No given physical interface name to delete"
            exit 1
        fi
        sudo ovs-vsctl del-port  br-dut $2 || echo "No given physical interface name to delete"
        sudo ovs-vsctl del-br br-dut
        #sudo ovs-vsctl remove open .  external-ids ovn-bridge-mappings=physnet1:br-dut
    ;;

    step3) echo "Add physical interface into br-serv to connect devices in physical network"
        # add ovn-bridge-mapping for physnet2
        # br-serv to connect ISP 
        if [ -z "$2" ] ; then 
            echo "No given physical interface name to add"
            exit 1
        fi
        sudo ovs-vsctl add-br br-serv
        mappings="physnet2:br-serv"
        old=`sudo ovs-vsctl get open .  external-ids:ovn-bridge-mappings`
        [ -n "$old"] & mappings="$mappings,$old"
        sudo ovs-vsctl set open .  external-ids:ovn-bridge-mappings=$mappings
        sudo ovs-vsctl set-controller br-serv tcp:$OF_MGMT_IP:6653
        sudo ovs-vsctl show 
        sudo ovs-vsctl list open .
        sudo ovs-vsctl add-port  br-serv $2 || echo "No given physical interface name to add"
    ;;

    clean3)
        if [ -z "$2" ] ; then 
            echo "No given physical interface name to delete"
            exit 1
        fi
        sudo ovs-vsctl del-port  br-serv $2 || echo "No given physical interface name to delete"
        sudo ovs-vsctl del-br br-serv
        #sudo ovs-vsctl remove open .  external-ids ovn-bridge-mappings=physnet2:br-serv
    ;;
