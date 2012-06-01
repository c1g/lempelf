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

# need libpcap and libcurses

#iftop
ver_iftop=iftop-0.17
file_iftop=iftop-0.17.tar.gz
url_iftop=http://www.ex-parrot.com/~pdw/iftop/download/iftop-0.17.tar.gz


#==== define function 
install_iftop(){
cd ${PACKAGEPATH}
tar xzvf $file_iftop
cd $ver_iftop
./configure
make
make install
echo "$ver_iftop -----ok!"
cd ..
sleep 1
return 0
}

#==== run function 
check_file "$file_iftop" "$url_iftop"

check_install "$ver_iftop" "iftop"
