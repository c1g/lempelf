#!/bin/bash
#########################################################################
#
# File:         setup_logwatch.sh
# Language:     GNU Bourne-Again SHell
# Version:	1.0
# Date:		2012-4-26
# Author:	c1g
# WWW:		http://blog.c1gstudio.com
# logwatch
### END INIT INFO


#==== define variable
if [[ ! -n ${MailUser} ]]; then
MailUser="root@localhost"
fi

install_logwatch(){
yum -y install logwatch
\cp -af /usr/share/logwatch/default.conf/logwatch.conf /etc/logwatch/conf/logwatch.conf
sed -i 's/# DailyReport = No/DailyReport = Yes/' /etc/logwatch/conf/logwatch.conf
sed -i 's/mailer = "sendmail -t"/mailer = "mail -t"/' /etc/logwatch/conf/logwatch.conf
sed -i 's/Detail = Low/Detail = High/' /etc/logwatch/conf/logwatch.conf
sed -i "s/MailTo = root/MailTo = root,$MailUser/" /etc/logwatch/conf/logwatch.conf
echo "logwatch -----ok!"

sleep 1
return 0
}

install_logwatch
