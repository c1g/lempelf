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
if [[ ! -n ${SSHPORT} ]]; then
SSHPORT=22
fi

#fail2ban
ver_fail2ban=fail2ban-0.8.4
file_fail2ban=fail2ban-0.8.4.tar.bz2
url_fail2ban=http://sourceforge.net/projects/fail2ban/files/fail2ban-stable/fail2ban-0.8.4/fail2ban-0.8.4.tar.bz2/download


#==== define function 
install_fail2ban(){
cd ${PACKAGEPATH}
tar xvfj $file_fail2ban
cd $ver_fail2ban
python setup.py install
\cp ./files/redhat-initd /etc/init.d/fail2ban
chkconfig --add fail2ban 
echo "$ver_fail2ban -----ok!"
cd ..
sleep 1
return 0
}

#==== run function 
check_file "$file_fail2ban" "$url_fail2ban"

check_install "$ver_fail2ban" "fail2ban"

#sed
sed -i '/\[ssh-iptables/{N;N;s/false/true/}' /etc/fail2ban/jail.conf
sed -i '/name=SSH, port=/{s/port=ssh/port=$SSHPORT/g}' /etc/fail2ban/jail.conf
sed -i '/\[ssh-iptables/{N;N;N;N;N;N;s/sshd.log/secure/}' /etc/fail2ban/jail.conf
sed -i '/\[ssh-iptables/{N;N;N;N;N;N;N;s/5/3/}' /etc/fail2ban/jail.conf


#copy log 
\cp ../conf/fail2ban /etc/logrotate.d/fail2ban
chown root:root /etc/logrotate.d/fail2ban
chmod 644 /etc/logrotate.d/fail2ban

#start fail2ban
/etc/init.d/fail2ban restart 


echo "install $ver_fail2ban -----ok!"
