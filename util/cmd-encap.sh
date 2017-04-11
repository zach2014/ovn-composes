#! /bin/bash
#
# cmd-encap.sh
# Copyright (C) 2017 zach <zacharyzjp@gmail.com>
#
# Distributed under terms of the MIT license.
#
#set -o xtrace

if [ -z "$OVS_CENTRAL_IP" ] ; then 
    cat <<EOF
    Warning: No enviroment variable: OVS_CENTRAL_IP, will use 127.0.0.1.
    Ctrl-c to abort...
EOF
    sleep 30
    OVS_CENTRAL_IP=127.0.0.1
fi 

ovs-vsctl-cmd() {
    cmd_rs=$(ovs-vsctl --db=tcp:$OVS_CENTRAL_IP:6640 "$@") 
}

ovn-nbctl-cmd() {
    cmd_rs=$(ovn-nbctl --db=tcp:$OVS_CENTRAL_IP:6641 "$@") 
}

ovn-sbctl-cmd() {
    cmd_rs=$(ovn-sbctl --db=tcp:$OVS_CENTRAL_IP:6642 "$@") 
}

ovn-trace-cmd() {
    cmd_rs=$(ovn-trace --db=tcp:$OVS_CENTRAL_IP:6642 "$@") 
}
