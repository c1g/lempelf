#!/bin/bash
#########################################################################
#
# File:         firstlog.sh
# Language:     GNU Bourne-Again SHell
# Version:	1.0
# Date:		2012-3-27
# Author:	c1g
# WWW:		http://blog.c1gstudio.com
# 生成文件及运行信息供以后入侵检测对比
### END INIT INFO

file_db_org=./log/firstlog.log

if [ ! -d log ];then
	mkdir log
	chmod 700 log
fi

servername=`hostname`
date=`date +%Y-%m-%d_%H`
time=`date +%Y/%m/%d/%H:%M:%S`

echo -e "host:${servername}========${time}======\r">> ${file_db_org}
echo -e "ps -aux ...\r">> ${file_db_org}
echo -e "======================================================\r">> ${file_db_org}
ps -aux >> ${file_db_org}

echo -e "\r\r">> ${file_db_org}
echo -e "chkconfig --list|grep 3:on ...\r">> ${file_db_org}
echo -e "======================================================\r">> ${file_db_org}
chkconfig --list|grep 3:on >> ${file_db_org}

echo -e "\r\r">> ${file_db_org}
echo -e "netstat -lnp ...\r">> ${file_db_org}
echo -e "======================================================\r">> ${file_db_org}
netstat -lnp >> ${file_db_org}

echo -e "\r\r">> ${file_db_org}
echo -e "find / -type f -perm -4000 -exec ls -l {} \; ...\r">> ${file_db_org}
echo -e "======================================================\r">> ${file_db_org}
find / -type f -perm -4000 -exec ls -l {} \;>> ${file_db_org}

echo -e "\r\r">> ${file_db_org}
echo -e "find / \( -path /home -o -path /root \) -prune -nouser -type f -exec ls -l {} \; ...\r">> ${file_db_org}
echo -e "======================================================\r">> ${file_db_org}
find / \( -path /home -o -path /root \) -prune -nouser -type f -exec ls -l {} \; >> ${file_db_org}

echo -e "\r\r">> ${file_db_org}
echo -e "rpm -Va ...\r">> ${file_db_org}
echo -e "======================================================\r">> ${file_db_org}
rpm -Va >> ${file_db_org}

chmod 600 ${file_db_org}