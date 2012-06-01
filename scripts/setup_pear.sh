#!/bin/bash
#==== path variable
if [[ ! -n ${BASEDIR} ]]; then
BASEDIR=$(cd "$(dirname "$0")";cd ..; pwd)
fi
PACKAGEPATH=${BASEDIR}/packages
echo "cd ${PACKAGEPATH}"
cd ${PACKAGEPATH}

. ${BASEDIR}/functions/check.sh

#==== define variable
if [[ ! -n ${SERVERPATH} ]]; then
SERVERPATH="/opt"
fi

chgrp website ${SERVERPATH}/php/etc/pear.conf
chmod 660 ${SERVERPATH}/php/etc/pear.conf

${SERVERPATH}/php/bin/pear upgrade pear 
${SERVERPATH}/php/bin/pear install Benchmark Cache_Lite DB HTTP Mail Mail_Mime Net_SMTP Net_Socket Pager XML_Parser XML_RPC 
echo "upgrade pear -----ok!"
