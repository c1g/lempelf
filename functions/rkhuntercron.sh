#!/bin/bash
#########################################################################
#
# File:         rkhunter.sh
# Language:     GNU Bourne-Again SHell
# Version:	1.0
# Date:		2012-4-16
# Author:	c1g
# WWW:		http://blog.c1gstudio.com
# 
### END INIT INFO

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

ToolkitsPath=/usr/local
MailUser=root@localhost
FileRkhunterLog=`pwd`/log/rkhuntercron.log

ServerName=`hostname`
Date=`date +%Y-%m-%d`
Time=`date +%Y/%m/%d/%H:%M:%S`
FileDirTmp=`dirname ${FileRkhunterLog}`

# we need root to run 
if test "`id -u`" -ne 0
then
	echo "You need root to run!"
	exit
fi
#create log dir
if [ ! -d ${FileDirTmp} ]; then
	mkdir ${FileDirTmp}
	chmod 700 ${FileDirTmp}
fi


${ToolkitsPath}/rkhunter/bin/rkhunter --cronjob -l ${FileRkhunterLog} --noappend-log --nomow --rwo
if [ ! -z "$(grep Warning ${FileRkhunterLog})" ]; then
grep -C 1 Warning ${FileRkhunterLog} | mail -s "[rkhunter] report ${ServerName} ${Date}" ${MailUser}
fi
