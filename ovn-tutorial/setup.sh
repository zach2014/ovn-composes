#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -o xtrace
. ../util/cmd-encap.sh
case $1 in 
    step1) echo "-----------------Step1-------------------------------- "
        # Create a logical switch named "sw0"
        ovn-nbctl-cmd ls-add sw0

        # Create two logical ports on "sw0".
        ovn-nbctl-cmd lsp-add sw0 sw0-port1
        ovn-nbctl-cmd lsp-add sw0 sw0-port2

        # Set a MAC address for each of the two logical ports.
        ovn-nbctl-cmd lsp-set-addresses sw0-port1 00:00:00:00:00:01
        ovn-nbctl-cmd lsp-set-addresses sw0-port2 00:00:00:00:00:02

        # Set up port security for the two logical ports.  This ensures that
        # the logical port mac address we have configured is the only allowed
        # source and destination mac address for these ports.
        ovn-nbctl-cmd lsp-set-port-security sw0-port1 00:00:00:00:00:01
        ovn-nbctl-cmd lsp-set-port-security sw0-port2 00:00:00:00:00:02

        ;;
    step2) echo "-----------------Step2-------------------------------- "
        ovn-nbctl-cmd lsp-add sw0 sw0-port3
        ovn-nbctl-cmd lsp-add sw0 sw0-port4

        ovn-nbctl-cmd lsp-set-addresses sw0-port3 00:00:00:00:00:03
        ovn-nbctl-cmd lsp-set-addresses sw0-port4 00:00:00:00:00:04

        ovn-nbctl-cmd lsp-set-port-security sw0-port3 00:00:00:00:00:03
        ovn-nbctl-cmd lsp-set-port-security sw0-port4 00:00:00:00:00:04

        # Create a fake remote chassis.
        ovn-sbctl-cmd chassis-add fakechassis geneve 127.0.0.1

        # Bind sw0-port3 and sw0-port4 to the fake remote chassis.
        ovn-sbctl-cmd lsp-bind sw0-port3 fakechassis
        ovn-sbctl-cmd lsp-bind sw0-port4 fakechassis

        ;;
    step3) echo "-----------------Step3-------------------------------- "
        ovs-vsctl-cmd add-br br-dut
        ovs-vsctl-cmd set open .  external-ids:ovn-bridge-mappings=physnet1:br-dut

        ovn-nbctl-cmd lsp-add sw0 sw0-physnet1
        ovn-nbctl-cmd lsp-set-addresses sw0-physnet1  unknown
        ovn-nbctl-cmd lsp-set-type sw0-physnet1 localnet
        ovn-nbctl-cmd lsp-set-options sw0-physnet1 network_name=physnet1

        ovn-nbctl-cmd ls-add sw1

        ovn-nbctl-cmd lsp-add sw1 sw1-port1
        ovn-nbctl-cmd lsp-set-addresses sw1-port1 00:00:00:00:00:11
        ovn-nbctl-cmd lsp-set-port-security sw1-port1 00:00:00:00:00:11

        ovn-nbctl-cmd lsp-add sw1 sw1-physnet1
        ovn-nbctl-cmd lsp-set-addresses sw1-physnet1  unknown
        ovn-nbctl-cmd lsp-set-type sw1-physnet1 localnet
        ovn-nbctl-cmd lsp-set-options sw1-physnet1 network_name=physnet1

        ;; 
    step4) echo "-----------------Step4-------------------------------- "
        # Create ports on the local OVS bridge, br-int.  When ovn-controller
        # sees these ports show up with an "iface-id" that matches the OVN
        # logical port names, it associates these local ports with the OVN
        # logical ports.  ovn-controller will then set up the flows necessary
        # for these ports to be able to communicate each other as defined by
        # the OVN logical topology.
        ovs-vsctl-cmd add-port br-int eth1 -- set Interface eth1 external_ids:iface-id=sw0-port1 -- set Interface eth1 ofport_request=3
        ovs-vsctl-cmd add-port br-int eth2 -- set Interface eth2 external_ids:iface-id=sw1-port1 -- set Interface eth2 ofport_request=4

        ;; 
    step5) echo "-----------------Step5-------------------------------- "
        ovn-nbctl-cmd ls-add sw2

        ovn-nbctl-cmd lsp-add sw2 sw2-port1
        ovn-nbctl-cmd lsp-set-addresses sw2-port1 00:00:00:00:00:21
        ovn-nbctl-cmd lsp-set-port-security sw2-port1 00:00:00:00:00:21

        ovn-sbctl-cmd lsp-bind sw2-port1 fakechassis

        ovn-nbctl-cmd lsp-add sw2 sw2-physnet1
        ovn-nbctl-cmd lsp-set-addresses sw2-physnet1  unknown
        ovn-nbctl-cmd lsp-set-type sw2-physnet1 localnet
        ovn-nbctl-cmd lsp-set-options sw2-physnet1 network_name=physnet1
        ;;

    p1) cat <<EOF
# Packet1:
# input from local interface, eth1 (ofport 3)
# destination MAC is sw1-port1 
# expect to go out via localnet port (ofport 15)
# to br-dut, and then flood, via localnet port(ofport 16) to go out eth2 (ofport 14)
EOF
        sudo ovs-appctl ofproto/trace br-int in_port=3,dl_src=00:00:00:00:00:01,dl_dst=00:00:00:00:00:11 -generate 
        ;;

    p2) cat <<EOF
# Packet2:
# input from localnet port (ofport 15/16)
# expect to be delivered to local interface, eth1/eth2 (ofport 3/4)
EOF
        sudo ovs-appctl ofproto/trace br-int in_port=15,dl_src=00:00:00:00:00:11,dl_dst=00:00:00:00:00:01 -generate
        sudo ovs-appctl ofproto/trace br-int in_port=16,dl_src=00:00:00:00:00:01,dl_dst=00:00:00:00:00:11 -generate
        ;;
        
    p3) cat <<EOF
# Packet3:
# input from local interface, eth1 (ofport 3)
# destination MAC is sw2-port1 
# expect to go out via localnet port (ofport 15)
EOF
        sudo ovs-appctl ofproto/trace br-int in_port=3,dl_src=00:00:00:00:00:01,dl_dst=00:00:00:00:00:21 -generate
        ;;
        
    p4) cat <<EOF
# Packet4:
# input from local interface, eth1 (ofport 13)
# destination MAC is broadcast 
EOF
        sudo ovs-appctl ofproto/trace br-int in_port=3,dl_src=00:00:00:00:00:01,dl_dst=ff:ff:ff:ff:ff:ff -generate
        ;;

    p5) cat <<EOF
# Packet5:
# input from local port (ofport 15/16)
# destination MAC is broadcast 
EOF
        sudo ovs-appctl ofproto/trace br-int in_port=15,dl_src=00:00:00:00:00:21,dl_dst=ff:ff:ff:ff:ff:ff -generate
        sudo ovs-appctl ofproto/trace br-int in_port=16,dl_src=00:00:00:00:00:21,dl_dst=ff:ff:ff:ff:ff:ff -generate
        ;;

    debug) echo "------------------packet for investifation-------------------------------: "
        echo "OVN trace packet from sw0-port1 to sw0-port2 sw0-port3 sw0-port4"
        ovn-trace-cmd --minimal sw0 'inport == "sw0-port1" && eth.src == 00:00:00:00:00:01 && eth.dst == 00:00:00:00:00:02' 
        ovn-trace-cmd --minimal sw0 'inport == "sw0-port1" && eth.src == 00:00:00:00:00:01 && eth.dst == 00:00:00:00:00:03' 
        ovn-trace-cmd --minimal sw0 'inport == "sw0-port1" && eth.src == 00:00:00:00:00:01 && eth.dst == 00:00:00:00:00:04' 
        ovn-trace-cmd --minimal sw0 'inport == "sw0-port1" && eth.src == 00:00:00:00:00:01 && eth.dst == 00:00:00:00:00:11' 
        #sudo ovs-appctl ofproto/trace br-int in_port=7,dl_src=00:00:00:00:00:03,dl_dst=00:00:00:00:00:02,tun_id=3,tun_metadata0=196610 -generate
        #sudo ovs-appctl ofproto/trace br-int in_port=7,dl_src=00:00:00:00:00:03,dl_dst=00:00:00:00:00:01,tun_id=3,tun_metadata0=196609 -generate 
        ;;

    info1) echo "-----------------Info1-------------------------------- "
        ovs-vsctl-cmd get Interface eth1 ofport
        echo "eth1 ofport num: $cmd_rs"
        ovs-vsctl-cmd get Interface eth2 ofport
        echo "eth2 ofport num: $cmd_rs"
        ;;

esac
