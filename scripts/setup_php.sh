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
ver_php=php-5.2.17 
file_php=php-5.2.17.tar.gz
url_php="http://us.php.net/get/php-5.2.17.tar.gz/from/cn2.php.net/mirror"

ver_phpfpm=php-5.2.17-fpm-0.5.14
file_phpfpm=php-5.2.17-fpm-0.5.14.diff.gz
url_phpfpm=http://php-fpm.org/downloads/php-5.2.17-fpm-0.5.14.diff.gz


ver_phphashpatch=laruence-laruence.github.com-b648cb1
file_phphashpatch=laruence-laruence.github.com-b648cb1.zip
url_phphashpatch="http://blog.c1gstudio.com/lempelf/laruence-laruence.github.com-b648cb1.zip"

ver_memcache=memcache-3.0.5
file_memcache=memcache-3.0.5.tgz 
url_memcache="http://pecl.php.net/get/memcache-3.0.5.tgz"  

ver_eaccelerator=eaccelerator-0.9.6.1
file_eaccelerator=eaccelerator-0.9.6.1.tar.bz2 
url_eaccelerator="http://downloads.sourceforge.net/project/eaccelerator/eaccelerator/eAccelerator%200.9.6.1/eaccelerator-0.9.6.1.tar.bz2?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Feaccelerator%2Ffiles%2Feaccelerator%2FeAccelerator%25200.9.6.1%2F&ts=1314069512&use_mirror=ncu"  

ver_pdomysql=PDO_MYSQL-1.0.2
file_pdomysql=PDO_MYSQL-1.0.2.tgz  
url_pdomysql="http://pecl.php.net/get/PDO_MYSQL-1.0.2.tgz"  

ver_imagemagick=ImageMagick-6.6.9-4
file_imagemagick=ImageMagick.tar.gz  
url_imagemagick="ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick.tar.gz"  

ver_imagick=imagick-2.2.2
file_imagick=imagick-2.2.2.tgz  
url_imagick="http://pecl.php.net/get/imagick-2.2.2.tgz"  

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
#64bit
ver_zendoptimizer=ZendOptimizer-3.3.9-linux-glibc23-x86_64
file_zendoptimizer=ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz  
url_zendoptimizer="http://blog.c1gstudio.com/lempelf/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz"
else
#32bit
ver_zendoptimizer=ZendOptimizer-3.3.9-linux-glibc23-i386
file_zendoptimizer=ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz 
url_zendoptimizer="http://blog.c1gstudio.com/lempelf/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz"  
fi


#==== define function 
install_php(){
cd ${PACKAGEPATH}
tar xzvf $file_php
gzip -cd $file_phpfpm | patch -d $ver_php -p1 
unzip -o $file_phphashpatch
cd $ver_php
patch -p1 < ../$ver_phphashpatch/php-5.2-max-input-vars/php-5.2.17-max-input-vars.patch
./configure --prefix=${SERVERPATH}/${ver_php} --with-config-file-path=${SERVERPATH}/${ver_php}/etc --with-mysql=${SERVERPATH}/mysql --with-mysqli=${SERVERPATH}/mysql/bin/mysql_config \
--with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --disable-rpath \
--enable-discard-path --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl \
--with-curlwrappers --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt \
--with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap \
--enable-xml --enable-zend-multibyte --disable-debug --disable-ipv6
make ZEND_EXTRA_LIBS='-liconv' 
make install

if [ -h ${SERVERPATH}/php ]; then
	rm -f ${SERVERPATH}/php
fi
ln -s ${SERVERPATH}/${ver_php}/ ${SERVERPATH}/php
\cp php.ini-dist ${SERVERPATH}/php/etc/php.ini
chgrp website ${SERVERPATH}/php/etc/php.ini
chmod 660 ${SERVERPATH}/php/etc/php.ini

echo "$ver_php -----ok!"
cd ..
sleep 1
return 0
}

install_memcache(){
cd ${PACKAGEPATH}
tar xzvf $file_memcache
cd $ver_memcache
${SERVERPATH}/php/bin/phpize 
./configure --with-php-config=${SERVERPATH}/php/bin/php-config 
make
make install
echo "$ver_memcache -----ok!"
cd ..
sleep 1
return 0
}

install_eaccelerator(){
cd ${PACKAGEPATH}
tar jxvf $file_eaccelerator 
cd $ver_eaccelerator
${SERVERPATH}/php/bin/phpize 
./configure  --enable-eaccelerator=shared --with-php-config=${SERVERPATH}/php/bin/php-config 
make 
make install 
echo "$ver_eaccelerator -----ok!"
cd ..
sleep 1
return 0
}

install_pdomysql(){
cd ${PACKAGEPATH}
tar zxvf $file_pdomysql 
cd $ver_pdomysql
${SERVERPATH}/php/bin/phpize 
./configure --with-php-config=${SERVERPATH}/php/bin/php-config --with-pdo-mysql=${SERVERPATH}/mysql 
make 
make install 
echo "$ver_pdomysql -----ok!"
cd ..
sleep 1
return 0
}

install_imagemagick(){
cd ${PACKAGEPATH}
tar zxvf $file_imagemagick 
cd $ver_imagemagick
./configure 
make 
make install 
echo "$ver_imagemagick -----ok!"
cd ..
sleep 1
return 0
}

install_imagick(){
cd ${PACKAGEPATH}
tar zxvf $file_imagick 
cd $ver_imagick
${SERVERPATH}/php/bin/phpize 
./configure --with-php-config=${SERVERPATH}/php/bin/php-config
make 
make install 
echo "$ver_imagick -----ok!"
cd ..
sleep 1
return 0
}

install_zendoptimizer(){
#ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp
cd ${PACKAGEPATH}
tar zxvf $file_zendoptimizer 
\cp -f ${ver_zendoptimizer}/data/5_2_x_comp/ZendOptimizer.so ${SERVERPATH}/php/lib/php/extensions/no-debug-non-zts-20060613/

if grep "\[Zend\]" "${SERVERPATH}/php/etc/php.ini" > /dev/null; then
echo "Note:Zend skip! "
else

cat >>${SERVERPATH}/php/etc/php.ini<<EOF
[Zend]
zend_extension="${SERVERPATH}/php/lib/php/extensions/no-debug-non-zts-20060613/ZendOptimizer.so"
zend_optimizer.enable_loader = 1
zend_optimizer.optimization_level=15
zend_optimizer.disable_licensing=0
EOF
echo "$ver_zendoptimizer -----ok!"
fi
cd ..
sleep 1
return 0
}

parse_php(){
cd ${PACKAGEPATH}
mkdir -p ${SERVERPATH}/php/eaccelerator_cache
chown www:website ${SERVERPATH}/php/eaccelerator_cache
chmod 770 ${SERVERPATH}/php/eaccelerator_cache

touch ${SERVERPATH}/php/logs/php_error.log
chown www:website ${SERVERPATH}/php/logs/php_error.log
chmod 660 ${SERVERPATH}/php/logs/php_error.log

mkdir -p ${SERVERPATH}/htdocs/www/nginx
#phpinfo
echo '<?php phpinfo(); ?>' > ${SERVERPATH}/htdocs/www/phpinfo.php
chmod -R 0775 ${SERVERPATH}/htdocs/ 
chown -R www:website ${SERVERPATH}/htdocs/

mkdir -p ${SERVERPATH}/lampp/htdocs/www/
chmod -R 0775 ${SERVERPATH}/lampp/htdocs/
chown -R www:website ${SERVERPATH}/lampp/htdocs/

\cp -f ../conf/php-fpm.conf ${SERVERPATH}/php/etc/
chgrp website ${SERVERPATH}/php/etc/php-fpm.conf
chmod 660 ${SERVERPATH}/php/etc/php-fpm.conf

#replace path
if [[ ${SERVERPATH} != "/opt" ]]; then
sed -i "s#\/opt#${SERVERPATH}#g"  ${SERVERPATH}/php/etc/php-fpm.conf
fi

if [ ! -d /tmp/upload ]; then
mkdir /tmp/upload
fi
if [ ! -d /tmp/session ]; then
mkdir /tmp/session
fi
chown www:website /tmp/upload
chmod 0770 /tmp/upload
chown www:website /tmp/session
chmod 0770 /tmp/session

#/etc/cron.daily/tmpwatch
if grep "/tmp/upload" "/etc/cron.daily/tmpwatch" > /dev/null; then
echo "Note:tmpwatch skip! "
else    
sed -i "s#.Test-unix#.Test-unix -x /tmp/upload -x /tmp/session#g" /etc/cron.daily/tmpwatch
echo "tmpwatch -----ok!"
fi
sleep 2


sed -i '/expose_php/ {s/On/Off/g};/magic_quotes_gpc/ {s/Off/On/g};/upload_max_filesize/ {s/.*/upload_max_filesize = 10M/};/output_buffering/ {s/Off/On/g}' ${SERVERPATH}/php/etc/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_NOTICE/error_reporting = E_WARNING \& E_ERROR/g' ${SERVERPATH}/php/etc/php.ini
sed -i '/display_errors/ {s/On/Off/g};/log_errors/ {s/Off/On/g}' ${SERVERPATH}/php/etc/php.ini
sed -i "s#;error_log = filename#error_log = ${SERVERPATH}/php/logs/php_error.log#g" ${SERVERPATH}/php/etc/php.ini
sed -i "s#;always_populate_raw_post_data = On#always_populate_raw_post_data = On#g" ${SERVERPATH}/php/etc/php.ini
sed -i "s#; cgi.fix_pathinfo = 1#cgi.fix_pathinfo = 0#g;s#; cgi.fix_pathinfo = 0#cgi.fix_pathinfo = 0#g" ${SERVERPATH}/php/etc/php.ini
sed -i "s#;include_path = \".:\/php\/includes\"#include_path = \".:${SERVERPATH}\/php\/lib\/php\"#g" ${SERVERPATH}/php/etc/php.ini
sed -i 's/;session.save_path = "\/tmp"/session.save_path = "\/tmp\/session"/g' ${SERVERPATH}/php/etc/php.ini
sed -i 's#;upload_tmp_dir =#upload_tmp_dir = "/tmp/upload"#g' ${SERVERPATH}/php/etc/php.ini

if grep "no-debug-non-zts-20060613" "${SERVERPATH}/php/etc/php.ini" > /dev/null; then
echo "Note:extension_dir skip! "
else
cat >>${SERVERPATH}/php/etc/php.ini<<EOF
extension_dir = "${SERVERPATH}/php/lib/php/extensions/no-debug-non-zts-20060613/"
extension = "memcache.so"
#extension = "pdo_mysql.so"
extension = "imagick.so"
EOF
fi
sleep 2

if grep "\[eaccelerator\]" "${SERVERPATH}/php/etc/php.ini" > /dev/null; then
echo "Note:eaccelerator skip! "
else
cat >>${SERVERPATH}/php/etc/php.ini<<EOF
[eaccelerator]
extension="eaccelerator.so"
eaccelerator.shm_size="64"
eaccelerator.cache_dir="${SERVERPATH}/php/eaccelerator_cache"
eaccelerator.enable="1"
eaccelerator.optimizer="1"
eaccelerator.check_mtime="1"
eaccelerator.debug="0"
eaccelerator.filter=""
eaccelerator.shm_max="0"
eaccelerator.shm_ttl="3600"
eaccelerator.shm_prune_period="3600"
eaccelerator.shm_only="0"
eaccelerator.compress="1"
eaccelerator.compress_level="9"
EOF
fi
sleep 2


echo "php.ini -----ok!"
sleep 1
return 0
}


#==== run function 
check_file $file_php $url_php
check_file $file_phpfpm $url_phpfpm
check_file $file_phphashpatch $url_phphashpatch
check_file $file_memcache $url_memcache
check_file $file_eaccelerator $url_eaccelerator
check_file $file_pdomysql $url_pdomysql
check_file $file_imagemagick $url_imagemagick
check_file $file_imagick $url_imagick
check_file $file_zendoptimizer $url_zendoptimizer

check_install $ver_php "php"
check_install $ver_memcache "memcache"
check_install $ver_eaccelerator "eaccelerator"
check_install $ver_pdomysql "pdomysql"
check_install $ver_imagemagick "imagemagick"
check_install $ver_imagick "imagick"

parse_php
check_install $ver_zendoptimizer "zendoptimizer"
