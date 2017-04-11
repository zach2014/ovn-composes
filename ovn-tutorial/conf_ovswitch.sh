#! /bin/sh
#
# conf_ovswitch.sh
# Copyright (C) 2017 zach <zacharyzjp@gmail.com>
#
# Distributed under terms of the MIT license.
#
sudo ovs-vsctl set Open_vSwitch . \
    external_ids:ovn-remote="tcp:10.11.59.40:6642" \
    external_ids:ovn-nb="tcp:10.11.59.40:6641" \
    external_ids:ovn-encap-ip=10.11.59.151 \
    external_ids:ovn-encap-type="geneve"
#sudo /usr/share/openvswitch/scripts/ovn-ctl restart_controller
