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
if [[ ! -n ${DEFAULTDOMAIN} ]]; then
DEFAULTDOMAIN="admin.server.com"
fi

#awstats
ver_awstats=awstats-6.8
file_awstats=awstats-6.8.tar.gz
url_awstats="http://downloads.sourceforge.net/project/awstats/AWStats/6.8/awstats-6.8.tar.gz?r=http%3A%2F%2Fblog.c1gstudio.com%2Farchives%2F231&ts=1303199860&use_mirror=nchc"

ver_geoip=GeoIP-1.4.7
file_geoip=GeoIP-1.4.7.tar.gz
url_geoip="http://geolite.maxmind.com/download/geoip/api/c/GeoIP-1.4.7.tar.gz"

ver_lib=lib
file_lib=lib.tgz
url_lib="http://www.chedong.com/tech/lib.tgz"

ver_geoipperl=Geo-IP-1.38
file_geoipperl=Geo-IP-1.38.tar.gz
url_geoipperl="http://geolite.maxmind.com/download/geoip/api/perl/Geo-IP-1.38.tar.gz"

ver_geolitecity=GeoLiteCity.dat
file_geolitecity=GeoLiteCity.dat.gz
url_geolitecity="http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz"

ver_geoipdat=GeoIP.dat
file_geoipdat=GeoIP.dat.gz
url_geoipdat="http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz"


#==== define function
install_awstats(){
cd ${PACKAGEPATH}
tar xzvf $file_awstats
\cp -a ./${ver_awstats}/ ${SERVERPATH}/
chown -R www:website ${SERVERPATH}/${ver_awstats}
chmod -R 0775 ${SERVERPATH}/${ver_awstats}
if [ -h ${SERVERPATH}/awstats ]; then
	rm -f ${SERVERPATH}/awstats
fi
ln -s ${SERVERPATH}/${ver_awstats}/ ${SERVERPATH}/awstats

echo "$ver_awstats -----ok!"
sleep 1
return 0
}

install_geoip(){
cd ${PACKAGEPATH}
tar zxvf $file_geoip
cd $ver_geoip
./configure
make 
make install
cd ..
echo "$ver_geoip -----ok!"
sleep 1
return 0
}

install_lib(){
cd ${PACKAGEPATH}
tar zxvf $file_lib
chown www:website ${ver_lib}/*
chmod 0775 ${ver_lib}/*
\cp -a ${ver_lib}/* ${SERVERPATH}/awstats/wwwroot/cgi-bin/lib/
echo "awstat lib -----ok!"
sleep 1
return 0
}

install_geoipperl(){
cd ${PACKAGEPATH}
tar zxvf "$file_geoipperl"
cd "$ver_geoipperl"
perl Makefile.PL LIBS='-L/usr/local/lib' INC='-I/usr/local/include'
make
make install
cd ..
echo "$ver_geoipperl -----ok!"
sleep 1
return 0
}

install_geolitecity(){
cd ${PACKAGEPATH}
gunzip -c $file_geolitecity > $ver_geolitecity
\cp $ver_geolitecity ${SERVERPATH}/awstats/wwwroot/cgi-bin/plugins/
chown www:website /${SERVERPATH}/awstats/wwwroot/cgi-bin/plugins/$ver_geolitecity
chmod 0755 ${SERVERPATH}/awstats/wwwroot/cgi-bin/plugins/$ver_geolitecity

echo "$ver_geolitecity -----ok!"
sleep 1
return 0
}

install_geoipdat(){
cd ${PACKAGEPATH}
gunzip -c $file_geoipdat > $ver_geoipdat
\cp $ver_geoipdat ${SERVERPATH}/awstats/wwwroot/cgi-bin/plugins/
chown www:website ${SERVERPATH}/awstats/wwwroot/cgi-bin/plugins/$ver_geoipdat
chmod 0755 ${SERVERPATH}/awstats/wwwroot/cgi-bin/plugins/$ver_geoipdat

echo "$ver_geoipdat -----ok!"
sleep 1
return 0
}

prase_awstats(){
cd ${PACKAGEPATH}

if [ ! -d /var/lib/awstats ]; then
mkdir /var/lib/awstats
fi
chmod 0775 /var/lib/awstats

#cd ${SERVERPATH}/awstats/tools/
#perl awstats_configure.pl

\cp ../conf/common.conf ${SERVERPATH}/awstats/wwwroot/cgi-bin/
chown www:website ${SERVERPATH}/awstats/wwwroot/cgi-bin/common.conf

if [ ! -d /etc/awstats ]; then
mkdir /etc/awstats
fi
\cp ../conf/awstats.admin.server.com.conf  /etc/awstats/
chown www:website /etc/awstats/awstats.admin.server.com.conf
chmod 664 /etc/awstats/awstats.admin.server.com.conf

\cp ../functions/awstats.pl ${SERVERPATH}/awstats/wwwroot/cgi-bin/
chown www:website ${SERVERPATH}/awstats/wwwroot/cgi-bin/awstats.pl
chmod 775 ${SERVERPATH}/awstats/wwwroot/cgi-bin/awstats.pl

\cp ../functions/awstats_update.sh ${SERVERPATH}/shell/
chown www:website ${SERVERPATH}/shell/awstats_update.sh
chmod 775 ${SERVERPATH}/shell/awstats_update.sh

#replace domain
if [[ ${DEFAULTDOMAIN} != "admin.server.com" ]]; then
mv /etc/awstats/awstats.admin.server.com.conf /etc/awstats/awstats.${DEFAULTDOMAIN}.conf
sed -i "s#admin.server.com#${DEFAULTDOMAIN}#g" /etc/awstats/awstats.${DEFAULTDOMAIN}.conf
sed -i "s#admin.server.com#${DEFAULTDOMAIN}#g" ${SERVERPATH}/shell/awstats_update.sh
fi
#replace path
if [[ ${SERVERPATH} != "/opt" ]]; then
sed -i "s#\/opt#${SERVERPATH}#g" ${SERVERPATH}/awstats/wwwroot/cgi-bin/common.conf
sed -i "s#\/opt#${SERVERPATH}#g" /etc/awstats/awstats.${DEFAULTDOMAIN}.conf
sed -i "s#\/opt#${SERVERPATH}#g" ${SERVERPATH}/shell/awstats_update.sh
fi


#crontab
if grep "awstats_update.sh" "/var/spool/cron/root" > /dev/null; then
echo "Note:awstats_update.sh skip! "
else
echo "10 5 * * * /bin/sh ${SERVERPATH}/shell/awstats_update.sh > /dev/null 2>&1" >> /var/spool/cron/root
echo "awstats_update.sh -----ok!"
fi
}

#==== run function 
check_file "$file_awstats" "$url_awstats"
check_file "$file_geoip" "$url_geoip"
check_file "$file_geoipperl" "$url_geoipperl"
check_file "$file_lib" "$url_lib"
check_file "$file_geolitecity" "$url_geolitecity"
check_file "$file_geoipdat" "$url_geoipdat"

check_install "$ver_awstats" "awstats"
check_install "$ver_geoip" "geoip"
check_install "$ver_geoipperl" "geoipperl"
check_install "$ver_lib" "lib"
check_install "$ver_geolitecity" "geolitecity"
check_install "$ver_geoipdat" "geoipdat"

prase_awstats


#view report
#http://admin.server.com/cgi-bin/awstats.pl?config=admin.server.com
