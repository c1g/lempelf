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

#fail2ban
ver_phpmyadmin=phpMyAdmin-3.5.1-all-languages
file_phpmyadmin=phpMyAdmin-3.5.1-all-languages.tar.gz
url_phpmyadmin="http://cdnetworks-kr-1.dl.sourceforge.net/project/phpmyadmin/phpMyAdmin/3.5.1/phpMyAdmin-3.5.1-all-languages.tar.gz"


install_phpmyadmin(){
cd ${PACKAGEPATH}
tar xzvf $file_phpmyadmin
\cp -a ./${ver_phpmyadmin}/ ${SERVERPATH}/htdocs/www/phpmyadmin
chown -R www:website ${SERVERPATH}/htdocs/www/phpmyadmin
chmod -R 0775 ${SERVERPATH}/htdocs/www/phpmyadmin
\cp -a ${SERVERPATH}/htdocs/www/phpmyadmin/config.sample.inc.php ${SERVERPATH}/htdocs/www/phpmyadmin/config.inc.php 
sed -i "/$cfg['Servers'][$i]['auth_type'] = 'cookie';/ {s/cookie/http/g};" ${SERVERPATH}/htdocs/www/phpmyadmin/config.inc.php 
sed -i "/$cfg['Servers'][$i]['auth_type'] = 'http';/ a\$cfg['Servers'][\$i]['hide_db'] = 'information_schema';" ${SERVERPATH}/htdocs/www/phpmyadmin/config.inc.php 
#echo >> "$cfg['servers'][$i]['hide_db'] = 'information_schema'; >> ${SERVERPATH}/htdocs/www/phpmyadmin/config.inc.php 
echo "$ver_phpmyadmin -----ok!"
sleep 1
return 0
}

#==== run function 
check_file "$file_phpmyadmin" "$url_phpmyadmin"

check_install "$ver_phpmyadmin" "phpmyadmin"

