#! /bin/sh
#
# conf_ovswitch.sh
# Copyright (C) 2017 zach <zacharyzjp@gmail.com>
#
# Distributed under terms of the MIT license.
#
set -o xtrace 
sudo ovs-appctl -t ovsdb-server ovsdb-server/add-remote ptcp:6640
sudo /usr/share/openvswitch/scripts/ovn-ctl restart_northd
sudo ovn-nbctl set-connection ptcp:6641
sudo ovn-sbctl set-connection ptcp:6642
