#!/bin/bash
#########################################################################
#
# File:         setup_rkhunter.sh
# Language:     GNU Bourne-Again SHell
# Version:	1.0
# Date:		2012-4-16
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
ver_rkhunter=rkhunter-1.3.8
file_rkhunter=rkhunter-1.3.8.tar.gz
url_rkhunter=http://nchc.dl.sourceforge.net/project/rkhunter/rkhunter/1.3.8/rkhunter-1.3.8.tar.gz 

install_rkhunter(){
cd ${PACKAGEPATH}
if [ ! -d ${ToolkitsPath}/rkhunter ] ; then
mkdir -p ${ToolkitsPath}/rkhunter
fi
tar xzvf $file_rkhunter
cd ${ver_rkhunter}
./installer.sh --layout custom ${ToolkitsPath}/rkhunter --install
echo "$ver_rkhunter -----ok!"
cd ..
sleep 1
return 0
}

parse_rkhunter(){
cd ${PACKAGEPATH}

${ToolkitsPath}/rkhunter/bin/rkhunter --update

sed -i '/#SCRIPTWHITELIST="\/sbin\/ifup/ {s/^#//g}' ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
sed -i '/#SCRIPTWHITELIST="\/usr\/bin\/groups"/ {s/^#//g}' ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
sed -i '/#ALLOWHIDDENDIR="\/etc\/.java"/ {s/^#//g}' ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
sed -i '/#ALLOWHIDDENDIR="\/dev\/.mdadm"/ {s/^#//g}' ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
sed -i '/#ALLOWHIDDENDIR="\/dev\/.udev/ {s/^#//g}' ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
sed -i '/#ALLOWHIDDENFILE="\/usr\/share\/man\/man1\/..1.gz"/ {s/^#//g}' ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
sed -i '/#ALLOWHIDDENFILE="\/usr\/bin\/.fipscheck.hmac"/ {s/^#//g}' ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
sed -i '/#ALLOWHIDDENFILE="\/usr\/bin\/.ssh.hmac"/ {s/^#//g}' ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
sed -i '/#ALLOWHIDDENFILE="\/usr\/sbin\/.sshd.hmac"/ {s/^#//g}' ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
echo 'SCRIPTWHITELIST=/usr/bin/ldd' >> ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
echo 'SCRIPTWHITELIST=/usr/bin/whatis' >> ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
echo 'SCRIPTWHITELIST=/usr/bin/GET' >> ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
echo 'ALLOWHIDDENFILE=/usr/share/man/man5/.k5login.5.gz' >>  ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
echo 'ALLOWDEVFILE="/dev/shm/nginx.pid"' >> ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
echo 'IGNORE_PRELINK_DEP_ERR="/bin/egrep /bin/fgrep /bin/grep /usr/bin/less" ' >> ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
echo 'APP_WHITELIST="openssl:0.9.8e sshd:4.3p2"' >> ${ToolkitsPath}/rkhunter/etc/rkhunter.conf
#注意openssl和sshd的版本号


${ToolkitsPath}/rkhunter/bin/rkhunter --propupd

if [ ! -d ${SERVERPATH}/shell ]; then
mkdir ${SERVERPATH}/shell 
fi
\cp ../functions/rkhuntercron.sh ${SERVERPATH}/shell/
chmod 700 ${SERVERPATH}/shell/rkhuntercron.sh

#replace toolkitspath and mailuser
echo "parse ${SERVERPATH}/shell/rkhuntercron.sh"
if [[ ${ToolkitsPath} != "/usr/local" ]]; then
	sed -i "s#ToolkitsPath=/usr/local#ToolkitsPath=${ToolkitsPath}#g" ${SERVERPATH}/shell/rkhuntercron.sh
fi
if [[ ${MailUser} != "root@localhost" ]]; then
	sed -i "s#MailUser=root@localhost#MailUser=${MailUser}#g" ${SERVERPATH}/shell/rkhuntercron.sh
fi

#crontab
echo "crontab "
if grep "rkhuntercron.sh" "/var/spool/cron/root" > /dev/null; then
echo "Note:rkhuntercron.sh skip! "
else
echo "45 5 * * * cd ${SERVERPATH}/shell && /bin/sh ${SERVERPATH}/shell/rkhuntercron.sh > /dev/null 2>&1" >> /var/spool/cron/root
echo "rkhuntercron.sh -----ok!"
fi

echo "use below command to find rootkit"
echo "${ToolkitsPath}/rkhunter/bin/rkhunter -c --sk "

}

check_file "$file_rkhunter" "$url_rkhunter"
check_install "$ver_rkhunter" "rkhunter"
parse_rkhunter
