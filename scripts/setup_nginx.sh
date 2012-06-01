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

ver_pcre=pcre-8.30 
file_pcre=pcre-8.30.tar.gz
url_pcre=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.30.tar.gz

ver_nginx=nginx-0.8.55
file_nginx=nginx-0.8.55.tar.gz
url_nginx=http://nginx.org/download/nginx-0.8.55.tar.gz


#==== define function 
install_pcre(){
cd ${PACKAGEPATH}
tar xzvf $file_pcre
cd $ver_pcre
./configure --enable-utf8 --enable-unicode-properties
make
make install

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
#64bit
ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1
else
ln -s /lib/libpcre.so.0.0.1 /lib/libpcre.so.1
fi

echo "$ver_pcre -----ok!"
cd ..
sleep 1
return 0
}

install_nginx(){
cd ${PACKAGEPATH}
tar xzvf $file_nginx
cd $ver_nginx
sed -i "s/`echo $ver_nginx |cut -d'-' -f2`/1.0/g" src/core/nginx.h
#sed -i 's/"nginx/"LEMP/g' src/core/nginx.h
#sed -i 's/"NGINX/"LEMPWS/g' src/core/nginx.h
./configure --user=www --group=website --prefix=${SERVERPATH}/$ver_nginx --with-http_stub_status_module --with-http_ssl_module 
# --with-http_sub_module --with-md5=/usr/lib --with-sha1=/usr/lib --with-http_gzip_static_module 
make
make install
if [ ! -d ${SERVERPATH}/${ver_nginx} ]; then
	echo "setup nginx -----error!"
	exit 1
fi
if [ -h ${SERVERPATH}/nginx ]; then
	rm -f ${SERVERPATH}/nginx
fi
ln -s ${SERVERPATH}/${ver_nginx}/ ${SERVERPATH}/nginx

if [ ! -e /lib/libpcre.so.1 ]; then
	ln -s /lib/libpcre.so.0.0.1 /lib/libpcre.so.1
fi

echo "$ver_nginx -----ok!"
cd ..
sleep 1
return 0
}

parse_nginx(){
cd ${PACKAGEPATH}
if [ ! -d ${SERVERPATH}/nginx ];then
echo "Error:${SERVERPATH}/nginx not exist!"
sleep 1
return 0
fi
chown -R www:website ${SERVERPATH}/nginx/logs/ 
chmod -R 0774 ${SERVERPATH}/nginx/logs/ 

\cp ../conf/nginx.conf ${SERVERPATH}/nginx/conf/
\cp ../conf/fcgi.conf ${SERVERPATH}/nginx/conf/
\cp ../conf/awstats.conf ${SERVERPATH}/nginx/conf/
\cp ../conf/htpasswd ${SERVERPATH}/nginx/conf/
#/opt/apache2/bin/htpasswd -cb /opt/nginx/conf/htpasswd admin admin

chown -R www:website ${SERVERPATH}/nginx/conf/ 
chmod -R 0774 ${SERVERPATH}/nginx/conf/

if [ ! -d ${SERVERPATH}/shell ]; then
mkdir ${SERVERPATH}/shell 
fi
\cp ../functions/nginx_log.sh ${SERVERPATH}/shell/

chgrp -R website ${SERVERPATH}/shell
chmod -R 774 ${SERVERPATH}/shell
echo "parse_nginx -----ok!"
sleep 2

#replace domain
sed -i "s#admin.server.com#${DEFAULTDOMAIN}#g" ${SERVERPATH}/nginx/conf/nginx.conf
#replace path
if [[ ${SERVERPATH} != "/opt" ]]; then
sed -i "s#\/opt#${SERVERPATH}#g" ${SERVERPATH}/nginx/conf/nginx.conf
sed -i "s#\/opt#${SERVERPATH}#g" ${SERVERPATH}/nginx/conf/awstats.conf
fi

#crontab
if grep "nginx_log.sh" "/var/spool/cron/root" > /dev/null; then
echo "Note:nginx_log.sh skip! "
else
echo "59 23 * * * /bin/sh ${SERVERPATH}/shell/nginx_log.sh > /dev/null 2>&1" >> /var/spool/cron/root
echo "nginx_log.sh -----ok!"
fi
}

#==== run function 
check_file $file_pcre $url_pcre
check_file $file_nginx $url_nginx

check_install $ver_pcre "pcre"
check_install $ver_nginx "nginx"

parse_nginx
