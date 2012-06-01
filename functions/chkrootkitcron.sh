#!/bin/bash
#########################################################################
#
# File:         chkrootkitcron.sh
# Language:     GNU Bourne-Again SHell
# Version:	1.0
# Date:		2012-4-6
# Author:	c1g
# WWW:		http://blog.c1gstudio.com
# ¶¨Ê±ÓÃchkrootkit¼ì²ârootkit
### END INIT INFO

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

ToolkitsPath=/usr/local
MailUser=root@localhost
FileChkrootkitLog=`pwd`/log/chkrootkitcron.log
FileChkrootkitDailyLog=`pwd`/log/chkrootkitdaily_`date +%Y`.log

ServerName=`hostname`
Date=`date +%Y-%m-%d`
Time=`date +%Y/%m/%d/%H:%M:%S`
FileDirTmp=`dirname ${FileChkrootkitLog}`

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

echo -e ====== ${ServerName} " \r${Time} \r" >>${FileChkrootkitDailyLog}

cd ${ToolkitsPath}/chkrootkit 
./chkrootkit > ${FileChkrootkitLog}
if [ ! -z "$(grep INFECTED ${FileChkrootkitLog})" ]; then
cat ${FileChkrootkitLog} >> ${FileChkrootkitDailyLog}
grep INFECTED ${FileChkrootkitLog} | mail -s "[chkrootkit] report ${ServerName} ${Date}" ${MailUser}
else
echo -e "none" >>${FileChkrootkitDailyLog}
fi
