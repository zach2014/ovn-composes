#! /bin/sh
#
# conf_ovswitch.sh
# Copyright (C) 2017 zach <zacharyzjp@gmail.com>
#
# Distributed under terms of the MIT license.
#
. ../util/env-check.sh

# set local host be ovn-controller, and centralized
sudo ovs-vsctl set Open_vSwitch . \
    external_ids:ovn-remote="tcp:$OVS_CENTRAL_IP:6642" \
    external_ids:ovn-nb="tcp:$OVS_CENTRAL_IP:6641" \
    external_ids:ovn-encap-ip=$OVS_HOST_IP \
    external_ids:ovn-encap-type="geneve"
sudo /usr/share/openvswitch/scripts/ovn-ctl restart_controller

