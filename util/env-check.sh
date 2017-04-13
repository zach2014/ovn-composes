#! /bin/sh
#
# env-check.sh
# Copyright (C) 2017 zach <zacharyzjp@gmail.com>
#
# Distributed under terms of the MIT license.
#


if [ -z "$OVS_CENTRAL_IP" ] ; then 
    cat <<EOF
Warning: No enviroment variable: OVS_CENTRAL_IP
Ctrl-c to "export OVS_CENTRAL_IP=10.11.59.40", Or input it now: 
EOF
    sleep 10
    read OVS_CENTRAL_IP
fi 

if [ -z "$OVS_HOST_IP" ] ; then 
    cat <<EOF
Warning: No enviroment variable: OVS_HOST_IP
Ctrl-c to "export OVS_HOST_IP=10.11.59.x" Or input it now: 
EOF
    sleep 10
    read OVS_HOST_IP
fi 

if [ -z "$OF_MGMT_IP" ] ; then 
    cat <<EOF
Warning: No enviroment variable: OF_MGMT_IP
Ctrl-c to "export OF_MGMT_IP=10.11.59.40", Or input it now: 
EOF
    sleep 10
    read OF_MGMT_IP
fi 

