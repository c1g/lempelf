#!/bin/bash
#########################################################################
#
# File:         setup_mailx.sh
# Language:     GNU Bourne-Again SHell
# Version:	1.0
# Date:		2012-4-10
# Author:	c1g
# WWW:		http://blog.c1gstudio.com
# heirloom mailx 
### END INIT INFO

#==== path variable
if [[ ! -n ${BASEDIR} ]]; then
BASEDIR=$(cd "$(dirname "$0")";cd ..; pwd)
fi
PACKAGEPATH=${BASEDIR}/packages
echo "cd ${PACKAGEPATH}"
cd ${PACKAGEPATH}

linuxvar=`cat /etc/issue.net |head -n1`
linuxvar=${linuxvar#*release}
linuxvar=${linuxvar:1:1}

. ${BASEDIR}/functions/check.sh

#==== define variable
if [[ ! -n ${SERVERPATH} ]]; then
SERVERPATH="/opt"
fi
if [[ ! -n ${ToolkitsPath} ]]; then
ToolkitsPath="/usr/local"
fi

#smtp server
MailFrom=mailuser@localhost
MailSmtp=mail.localhost
MailSmtpAuthUser="mailuser"
MailSmtpAuthPassword="mailpassword"

#heirloom mailx
#http://sourceforge.net/projects/heirloom/
ver_mailx=mailx-12.4
file_mailx=mailx-12.4.tar.bz2
url_mailx="http://nchc.dl.sourceforge.net/project/heirloom/heirloom-mailx/12.4/mailx-12.4.tar.bz2"

install_mailx(){
cd ${PACKAGEPATH}
tar xjvf $file_mailx
cd ${ver_mailx}
make
make install UCBINSTALL=/usr/bin/install
echo "$ver_mailx -----ok!"

cd ..
sleep 1
return 0
}

parse_nail(){
cd ${PACKAGEPATH}
echo "/etc/nail.rc"
if grep "${MailSmtp}" "/etc/nail.rc" > /dev/null; then
echo "Note:nail.rc skip! "
else
cat >>/etc/nail.rc<<EOF
set from=${MailFrom}
set smtp=${MailSmtp}
set smtp-auth=login
set smtp-auth-user=${MailSmtpAuthUser}
set smtp-auth-password=${MailSmtpAuthPassword}
EOF
fi

if [ ! -h /bin/mail ]; then
	mv /bin/mail /bin/mail.OFF
	ln -s /usr/local/bin/mailx /bin/mail
	echo "mv /bin/mail /bin/mail.OFF"
	echo "ln -s /usr/local/bin/mailx /bin/mail"
else
	rm -f /bin/mail
	ln -s /usr/local/bin/mailx /bin/mail
	echo "rm -f /bin/mail"
	echo "ln -s /usr/local/bin/mailx /bin/mail"
fi

#libiconv.so.2
if grep "/usr/local/lib" "/etc/ld.so.conf" > /dev/null; then
	echo "Note:/usr/local/lib skip! "
else
	echo "echo '/usr/local/lib' >> /etc/ld.so.conf! "
	echo "/usr/local/lib" >> /etc/ld.so.conf
	ldconfig
fi

}

parse_mail(){
cd ${PACKAGEPATH}
echo "/etc/mail.rc"
if grep "${MailSmtp}" "/etc/mail.rc" > /dev/null; then
echo "Note:mail.rc skip! "
else
cat >>/etc/mail.rc<<EOF
set from=${MailFrom}
set smtp=${MailSmtp}
set smtp-auth=login
set smtp-auth-user=${MailSmtpAuthUser}
set smtp-auth-password=${MailSmtpAuthPassword}
EOF
fi

}

if [ ${linuxvar} == 6 ]; then
	if [ -z `rpm -qa mailx` ]; then
		parse_mail
	else
		yum -y install mailx
		parse_mail
	fi

else
	rpm -qa mailx
	check_file "$file_mailx" "$url_mailx"
	check_install "$ver_mailx" "mailx"
	parse_nail
fi

