#!/bin/bash
#########################################################################
#
# File:         setup_chkrootkit.sh
# Language:     GNU Bourne-Again SHell
# Version:	1.0
# Date:		2012-4-6
# Author:	c1g
# WWW:		http://blog.c1gstudio.com
# check rootkit
### END INIT INFO

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
if [[ ! -n ${ToolkitsPath} ]]; then
ToolkitsPath="/usr/local"
fi
if [[ ! -n ${MailUser} ]]; then
MailUser="root@localhost"
fi

#chkrootkit
ver_chkrootkit=chkrootkit-0.49
file_chkrootkit=chkrootkit-0.49.tar.gz
#ftp://ftp.pangeia.com.br/pub/seg/pac/chkrootkit.tar.gz
url_chkrootkit=http://blog.c1gstudio.com/lempelf/chkrootkit-0.49.tar.gz 

install_chkrootkit(){
cd ${PACKAGEPATH}
tar xzvf $file_chkrootkit
cd ${ver_chkrootkit}*
make sense
#if [ ! -d  ${ToolkitsPath}/chkrootkit ]; then
#	 mkdir ${ToolkitsPath}/chkrootkit
#fi
cd ..
mv -f ${ver_chkrootkit} chkrootkit
mv -f chkrootkit ${ToolkitsPath}/
chown -R root:root ${ToolkitsPath}/chkrootkit
chmod -R 700 ${ToolkitsPath}/chkrootkit
#rm -r chkrootkit-*
echo "${ver_chkrootkit} -----ok!"
echo "use below command to find rootkit"
echo "cd ${ToolkitsPath}/chkrootkit && ./chkrootkit | grep INFECTED"
cd ..
sleep 1
return 0
}

parse_chkrootkit(){
cd ${PACKAGEPATH}
if [ ! -d ${SERVERPATH}/shell ]; then
mkdir ${SERVERPATH}/shell 
fi
\cp ../functions/chkrootkitcron.sh ${SERVERPATH}/shell/
chmod 700 ${SERVERPATH}/shell/chkrootkitcron.sh

#replace toolkitspath and mailuser
echo "parse ${SERVERPATH}/shell/chkrootkitcron.sh"
if [[ ${ToolkitsPath} != "/usr/local" ]]; then
	sed -i "s#ToolkitsPath=/usr/local#ToolkitsPath=${ToolkitsPath}#g" ${SERVERPATH}/shell/chkrootkitcron.sh
fi
if [[ ${MailUser} != "root@localhost" ]]; then
	sed -i "s#MailUser=root@localhost#MailUser=${MailUser}#g" ${SERVERPATH}/shell/chkrootkitcron.sh
fi

#crontab
echo "crontab "
if grep "chkrootkitcron.sh" "/var/spool/cron/root" > /dev/null; then
echo "Note:chkrootkitcron.sh skip! "
else
echo "40 5 * * * cd ${SERVERPATH}/shell && /bin/sh ${SERVERPATH}/shell/chkrootkitcron.sh > /dev/null 2>&1" >> /var/spool/cron/root
echo "chkrootkitcron.sh -----ok!"
fi

}

check_file "$file_chkrootkit" "$url_chkrootkit"
check_install "$ver_chkrootkit" "chkrootkit"
parse_chkrootkit
