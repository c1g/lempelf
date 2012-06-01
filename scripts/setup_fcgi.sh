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
ver_fcgi=FCGI-0.71 
file_fcgi=FCGI-0.71.tar.gz 
url_fcgi=http://www.cpan.org/modules/by-module/FCGI/FCGI-0.71.tar.gz


#==== define function 
install_fcgi(){
cd ${PACKAGEPATH}
tar xzvf $file_fcgi
cd $ver_fcgi
/usr/bin/perl Makefile.PL
make
make install
echo "$ver_fcgi -----ok!"
cd ..
sleep 1
return 0
}

#==== run function 
check_file "$file_fcgi" $url_fcgi

check_install "$ver_fcgi" "fcgi"

cd ${PACKAGEPATH}
\cp ../functions/perl-fcgi.pl ${SERVERPATH}/shell/
chgrp website ${SERVERPATH}/shell/perl-fcgi.pl
chmod 770 ${SERVERPATH}/shell/perl-fcgi.pl
