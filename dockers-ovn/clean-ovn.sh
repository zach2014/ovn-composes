#! /bin/sh
#
# clean-ovn.sh
# Copyright (C) 2017 zach <zacharyzjp@gmail.com>
#
# Distributed under terms of the MIT license.
#

set -o xtrace 
. ../util/cmd-encap.sh
if [ $# -lt 2 ]; then 
    cat <<EOF
    $0 <logical switch name> <image name>
EOF
    exit 1
fi

LSW=$1
IMAGE=$2

ovn-nbctl-cmd lsp-del $LSW-2physnet
docker network rm $LSW  
docker network ls 
docker stop $(docker ps -q --filter "ancestor=$IMAGE") 
