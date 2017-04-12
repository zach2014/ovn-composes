#! /bin/bash
#
# cmd-encap.sh
# Copyright (C) 2017 zach <zacharyzjp@gmail.com>
#
# Distributed under terms of the MIT license.
#
#set -o xtrace

. ../util/env-check.sh
# encapsulate the ovs/ovn command with the specific database
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
