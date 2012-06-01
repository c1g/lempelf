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
ver_libiconv=libiconv-1.13
file_libiconv=libiconv-1.13.tar.gz
url_libiconv=http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.13.tar.gz 

ver_libmcrypt=libmcrypt-2.5.8
file_libmcrypt=libmcrypt-2.5.8.tar.gz 
url_libmcrypt="http://downloads.sourceforge.net/mcrypt/libmcrypt-2.5.8.tar.gz?modtime=1171868460&big_mirror=0"  

ver_mhash=mhash-0.9.9.9
file_mhash=mhash-0.9.9.9.tar.gz 
url_mhash="http://downloads.sourceforge.net/mhash/mhash-0.9.9.9.tar.gz?modtime=1175740843&big_mirror=0"  

ver_mcrypt=mcrypt-2.6.8
file_mcrypt=mcrypt-2.6.8.tar.gz  
url_mcrypt="http://downloads.sourceforge.net/mcrypt/mcrypt-2.6.8.tar.gz?modtime=1194463373&big_mirror=0"  

ver_mysql=mysql-5.1.26-rc
file_mysql=mysql-5.1.26-rc.tar.gz  
url_mysql="http://blog.c1gstudio.com/lempelf/mysql-5.1.26-rc.tar.gz"  

ver_PerconaMysql=Percona-Server-5.5.22-rel25.2
file_PerconaMysql=Percona-Server-5.5.22-rel25.2.tar.gz 
url_PerconaMysql="http://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-5.5.22-25.2/source/Percona-Server-5.5.22-rel25.2.tar.gz"  

#mysql root passwod
if [[ ! -n ${MYSQLROOTPWD} ]]; then
MYSQLROOTPWD="admin"
fi


#==== define function 
install_libiconv(){
cd ${PACKAGEPATH}
tar xzvf $file_libiconv
cd $ver_libiconv
./configure
make
make install
cd ..
#需要回到初始路径,否则会连带执行下面函数
echo "$ver_libiconv -----ok!"
sleep 1
return 0
}

install_libmcrypt(){
cd ${PACKAGEPATH}
tar xzvf $file_libmcrypt
cd $ver_libmcrypt
./configure
make
make install
/sbin/ldconfig 
cd libltdl/ 
./configure --enable-ltdl-install 
make 
make install 
cd ../../
echo "$ver_libmcrypt -----ok!"
sleep 1
return 0
}

install_mhash(){
cd ${PACKAGEPATH}
tar xzvf $file_mhash
cd $ver_mhash
./configure
make
make install
ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la 
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so 
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4 
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8 
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a 
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la 
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so 
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2 
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
/sbin/ldconfig
cd ..
echo "$ver_mhash -----ok!"
sleep 1
return 0
}

install_mcrypt(){
cd ${PACKAGEPATH}
ln -s   /usr/local/bin/libmcrypt-config   /usr/bin/libmcrypt-config
tar xzvf $file_mcrypt
cd $ver_mcrypt
./configure
make
make install
cd ..
echo "$ver_mcrypt -----ok!"
sleep 1
return 0
}

install_PerconaMysql(){
cd ${PACKAGEPATH}
tar zxvf $file_PerconaMysql 
cd $ver_PerconaMysql 
  
CC=gcc CFLAGS="-DBIG_JOINS=1 -DHAVE_DLOPEN=1 -O3" CXX=g++ CXXFLAGS="-DBIG_JOINS=1 -DHAVE_DLOPEN=1 -felide-constructors -fno-rtti -O3"
cmake . \
  -DCMAKE_BUILD_TYPE:STRING=Release             \
  -DSYSCONFDIR:PATH=${SERVERPATH}/${ver_PerconaMysql}            \
  -DCMAKE_INSTALL_PREFIX:PATH=${SERVERPATH}/${ver_PerconaMysql}  \
  -DENABLED_PROFILING:BOOL=ON                   \
  -DENABLE_DEBUG_SYNC:BOOL=OFF                  \
  -DMYSQL_DATADIR:PATH=${SERVERPATH}/${ver_PerconaMysql}/var    \
  -DMYSQL_MAINTAINER_MODE:BOOL=OFF              \
  -DWITH_EXTRA_CHARSETS=all  \
  -DWITH_BIG_TABLES:BOOL=ON \
  -DWITH_FAST_MUTEXES:BOOL=ON \
  -DENABLE-PROFILING:BOOL=ON \
  -DWITH_SSL:STRING=bundled                     \
  -DWITH_UNIT_TESTS:BOOL=OFF                    \
  -DWITH_ZLIB:STRING=bundled                    \
  -DWITH_PARTITION_STORAGE_ENGINE:BOOL=ON       \
  -DWITHOUT_PERFSCHEMA_STORAGE_ENGINE=1        \
  -DWITH_PLUGINS=heap,csv,partition,innodb_plugin,myisam \
  -DEFAULT_COLLATION=utf8_general_ci            \
  -DEFAULT_CHARSET=utf8                            \
  -DENABLED_ASSEMBLER:BOOL=ON                   \
  -DENABLED_LOCAL_INFILE:BOOL=ON                \
  -DENABLED_THREAD_SAFE_CLIENT:BOOL=ON          \
  -DENABLED_EMBEDDED_SERVER:BOOL=OFF             \
  -DWITH_CLIENT_LDFLAGS:STRING=all-static                 \
  -DINSTALL_LAYOUT:STRING=STANDALONE            \
  -DCOMMUNITY_BUILD:BOOL=ON;
make 
make install
echo "$ver_PerconaMysql -----ok!"
if [ -h ${SERVERPATH}/mysql ]; then
	rm -f ${SERVERPATH}/mysql
fi
ln -s ${SERVERPATH}/${ver_PerconaMysql}/ ${SERVERPATH}/mysql
rm -f /etc/my.cnf
\cp ../../conf/Perconamy.cnf ${SERVERPATH}/mysql/my.cnf

#replace path
if [[ ${SERVERPATH} != "/opt" ]]; then
sed -i "s#\/opt#${SERVERPATH}#g" ${SERVERPATH}/mysql/my.cnf 
fi


chown mysql:website ${SERVERPATH}/mysql/my.cnf 
chmod 0664 ${SERVERPATH}/mysql/my.cnf

chmod 755 ./scripts/mysql_install_db

./scripts/mysql_install_db --defaults-file=${SERVERPATH}/mysql/my.cnf --basedir=${SERVERPATH}/mysql --datadir=${SERVERPATH}/mysql/var --user=mysql --pid-file=${SERVERPATH}/mysql/var/mysql.pid --socket=${SERVERPATH}/mysql/mysql.sock
echo "mysql_install_db -----ok!"
chmod +w ${SERVERPATH}/mysql/ 
chown -R mysql:mysql ${SERVERPATH}/mysql/ 

\cp -f support-files/mysql.server ${SERVERPATH}/mysql/bin/
chown mysql:mysql ${SERVERPATH}/mysql/bin/mysql.server 
chmod 755 ${SERVERPATH}/mysql/bin/mysql.server 

${SERVERPATH}/mysql/bin/mysql.server start
sleep 1
${SERVERPATH}/mysql/bin/mysqladmin -uroot  password $MYSQLROOTPWD 
${SERVERPATH}/mysql/bin/mysql -S ${SERVERPATH}/mysql/mysql.sock -uroot -p${MYSQLROOTPWD} -e "DELETE FROM mysql.user WHERE Password='';DROP USER ''@'%';FLUSH PRIVILEGES;";
${SERVERPATH}/mysql/bin/mysql.server stop

if [ ! -e /etc/ld.so.conf.d/${ver_PerconaMysql}.conf ]; then
	echo "${SERVERPATH}/${ver_PerconaMysql}/lib" > /etc/ld.so.conf.d/${ver_PerconaMysql}.conf
	echo "mysql ldconfig-----ok!"
fi
ldconfig 

if [ -f /tmp/mysql.sock ]; then
	rm -f /tmp/mysql.sock
fi
ln -s /opt/mysql/mysql.sock /tmp/mysql.sock

rmdir /opt/mysql/var/test
echo "delete test database -----ok!"

cd ..
echo "mysql -----ok!"
sleep 1
return 0
}

install_mysql(){
cd ${PACKAGEPATH}
tar zxvf $file_mysql 
cd $ver_mysql 
  
CFLAGS="-O3" 
CXX=gcc 
CXXFLAGS="-O3 -felide-constructors -fno-exceptions -fno-rtti" 
./configure --prefix=${SERVERPATH}/${ver_mysql} --localstatedir=${SERVERPATH}/${ver_mysql}/var --sysconfdir=${SERVERPATH}/mysql \
--with-unix-socket-path=${SERVERPATH}/mysql/mysql.sock --with-charset=gbk --with-collation=gbk_chinese_ci --with-extra-charsets=gbk,gb2312,utf8 \
--with-client-ldflags=-all-static --with-mysqld-ldflags=-all-static --enable-assembler --without-debug --with-big-tables --with-readline \
--with-ssl --with-pthread --enable-thread-safe-client --with-embedded-server --enable-local-infile --with-plugins=innobase 
make 
make install
echo "$ver_mysql -----ok!"
if [ -h ${SERVERPATH}/mysql ]; then
	rm -f ${SERVERPATH}/mysql
fi
ln -s ${SERVERPATH}/${ver_mysql}/ ${SERVERPATH}/mysql
rm -f /etc/my.cnf
\cp ../../conf/my.cnf ${SERVERPATH}/mysql/

#replace path
if [[ ${SERVERPATH} != "/opt" ]]; then
sed -i "s#\/opt#${SERVERPATH}#g" ${SERVERPATH}/mysql/my.cnf 
fi


chown mysql:website ${SERVERPATH}/mysql/my.cnf 
chmod 0664 ${SERVERPATH}/mysql/my.cnf

${SERVERPATH}/mysql/bin/mysql_install_db --defaults-file=${SERVERPATH}/mysql/my.cnf --basedir=${SERVERPATH}/mysql --datadir=${SERVERPATH}/mysql/var --user=mysql --pid-file=${SERVERPATH}/mysql/var/mysql.pid --skip-locking --socket=${SERVERPATH}/mysql/mysql.sock
echo "mysql_install_db -----ok!"
chmod +w ${SERVERPATH}/mysql/ 
chown -R mysql:mysql ${SERVERPATH}/mysql/ 

\cp -f support-files/mysql.server ${SERVERPATH}/mysql/bin/
chown mysql:mysql ${SERVERPATH}/mysql/bin/mysql.server 
chmod 755 ${SERVERPATH}/mysql/bin/mysql.server 

${SERVERPATH}/mysql/bin/mysql.server start
sleep 1
${SERVERPATH}/mysql/bin/mysqladmin -uroot  password $MYSQLROOTPWD 
${SERVERPATH}/mysql/bin/mysql -S ${SERVERPATH}/mysql/mysql.sock -uroot -p${MYSQLROOTPWD} -e "DELETE FROM mysql.user WHERE Password='';DROP USER ''@'%';FLUSH PRIVILEGES;";
${SERVERPATH}/mysql/bin/mysql.server stop

if [ ! -e /etc/ld.so.conf.d/${ver_mysql}.conf ]; then
	echo "${SERVERPATH}/${ver_mysql}/lib" > /etc/ld.so.conf.d/${ver_mysql}.conf
	echo "mysql ldconfig-----ok!"
fi
ldconfig 

if [ -f /tmp/mysql.sock ]; then
	rm -f /tmp/mysql.sock
fi
ln -s /opt/mysql/mysql.sock /tmp/mysql.sock

rmdir /opt/mysql/var/test
echo "delete test database -----ok!"

cd ..
echo "mysql -----ok!"
sleep 1
return 0
}

#==== run function 
check_file $file_libiconv $url_libiconv
check_file $file_libmcrypt $url_libmcrypt
check_file $file_mhash $url_mhash
check_file $file_mcrypt $url_mcrypt
#check_file $file_mysql $url_mysql
check_file $file_PerconaMysql $url_PerconaMysql

check_install $ver_libiconv "libiconv"
check_install $ver_libmcrypt "libmcrypt"
check_install $ver_mhash "mhash"
check_install $ver_mcrypt "mcrypt"
#check_install $ver_mysql "mysql"
check_install $ver_PerconaMysql "PerconaMysql"
