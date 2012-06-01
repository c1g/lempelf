#!/bin/bash
#==== define variable
if [[ ! -n ${WORKUSER} ]]; then
WORKUSER=andychu
fi
#work user
/usr/sbin/groupadd website 
if egrep ${WORKUSER} /etc/passwd > /dev/null
then
	echo "useradd ${WORKUSER} skip!"
else
	/usr/sbin/useradd -g website ${WORKUSER} 
	/usr/bin/passwd ${WORKUSER}
	echo "useradd ${WORKUSER} -----ok!"
fi

#nginx and php
/usr/sbin/useradd -g website www -d /dev/null -s /sbin/nologin
echo "useradd www -----ok!"

#mysql
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql -d /dev/null -s /sbin/nologin
echo "useradd mysql -----ok!"

