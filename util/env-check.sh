#! /bin/sh
#
# env-check.sh
# Copyright (C) 2017 zach <zacharyzjp@gmail.com>
#
# Distributed under terms of the MIT license.
#


if [ -z "$OVS_CENTRAL_IP" ] ; then 
    cat <<EOF
    Warning: No enviroment variable: OVS_CENTRAL_IP, will use 127.0.0.1.
    Ctrl-c to abort...
EOF
    sleep 30
    OVS_CENTRAL_IP=127.0.0.1
fi 

if [ -z "$OVS_HOST_IP" ] ; then 
    cat <<EOF
    Warning: No enviroment variable: OVS_HOST_IP, will use 127.0.0.1.
    Ctrl-c to abort...
EOF
    sleep 30
    OVS_HOST_IP=127.0.0.1
fi 

if [ -z "$OF_MGMT_IP" ] ; then 
    cat <<EOF
    Warning: No enviroment variable: OF_MGMT_IP, will use 10.11.59.179 
    Ctrl-c to abort...
EOF
    sleep 30
    OF_MGMT_IP=10.11.59.179
fi 

