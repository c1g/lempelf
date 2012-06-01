#!/bin/bash

#==== path variable
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

BASEDIR=$(cd "$(dirname "$0")"; pwd)

#==== define variable
#mysql root passwod
MYSQLROOTPWD="admin"
#server path
SERVERPATH="/opt"
#work user(su;sudo)
WORKUSER=andychu
#default domain
DEFAULTDOMAIN="admin.server.com"
#default ssh port
SSHPORT="22"
#==== check root
if [ $(id -u) != "0" ]; then
    printf "Error: You must be root to run this script!\n"
    exit 1
fi

copyright(){
cat << EOF
+------------------------------------------------------------------+
|     === Welcome to LempElf for CentOS/RHEL  Installation! ===    |
+------------------------------------------------------------------+
|  A tool to auto-compile & install Nginx+MySQL+PHP on Linux       |
+------------------------------------------------------------------+
|                                                                  |
| Version: 1.1.0                                                   |
| Release Date: 2011-6-1                                           |
| Author: C1G                                                      |
| URL:    http://blog.c1gstudio.com                                |
+------------------------------------------------------------------+
EOF

read -p "Now, I'll install LEMP Are you sure?(y/n)" LEMP
case "$LEMP" in
y|Y)
    ;;
*)
    exit 0
    ;;
esac
}

copyright

#Start Install
cd ${BASEDIR}

. ${BASEDIR}/scripts/basic.sh

. ${BASEDIR}/scripts/add_user.sh

. ${BASEDIR}/scripts/setup_mysql.sh

. ${BASEDIR}/scripts/setup_php.sh

. ${BASEDIR}/scripts/setup_nginx.sh

. ${BASEDIR}/scripts/setup_fcgi.sh

. ${BASEDIR}/scripts/setup_phpmyadmin.sh

. ${BASEDIR}/scripts/setup_awstats.sh

. ${BASEDIR}/scripts/setup_pear.sh

. ${BASEDIR}/scripts/default_firewall.sh

. ${BASEDIR}/scripts/setup_fail2ban.sh

. ${BASEDIR}/scripts/setup_iftop.sh

. ${BASEDIR}/scripts/autosafe.sh

. ${BASEDIR}/scripts/tuning.sh

\cp ${BASEDIR}/functions/lemp ${SERVERPATH}/
chown root:website ${SERVERPATH}/lemp
chmod 760 ${SERVERPATH}/lemp

#replace path
if [[ ${SERVERPATH} != "/opt" ]]; then
sed -i "s#\/opt#${SERVERPATH}#g" ${SERVERPATH}/lemp
fi

read -p "do you want start services on startup?(y/n)" startup
if [ $startup = "y" ]; then
	if grep "lemp" "/etc/rc.local" > /dev/null; then
		echo "Note:start on startup skip! "
	else
		echo '/opt/lemp start' >> /etc/rc.local
	fi
fi


cat << EOF
+------------------------------------------------------------------+
|  LempElf Installation is complete
+------------------------------------------------------------------+
|  work user: $WORKUSER
|  web user: www
|  mysql user: mysql
|  mysql password: $MYSQLROOTPWD
|  web panel user: admin
|  web panel password: admin
|  The path of some dirs:
|  server path: $SERVERPATH
|  mysql path: ${SERVERPATH}/mysql/my.cnf
|  nginx path: ${SERVERPATH}/nginx/conf/nginx.conf
|  php path: ${SERVERPATH}/php/etc/php.ini
|  awstats path: /etc/awstats/
|  phpinfo: http://${DEFAULTDOMAIN}/phpinfo.php
|  phpmyadmin: http://${DEFAULTDOMAIN}/phpmyadmin/
|  awstats: http://${DEFAULTDOMAIN}/cgi-bin/awstats.pl?config=${DEFAULTDOMAIN}
|  web panel file: ${SERVERPATH}/nginx/conf/htpasswd
|  
|  start service: ${SERVERPATH}/lemp start
+------------------------------------------------------------------+
EOF
