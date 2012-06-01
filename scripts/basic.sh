#!/bin/bash
#nameserver
if grep -i "nameserver" "/etc/resolv.conf" > /dev/null; then
echo "Note:nameserver skip! "
else
cat >>/etc/resolv.conf<<EOF
nameserver 202.96.209.133
nameserver 8.8.8.8
EOF
fi
echo "nameserver -----ok!"

#yum
cd /etc/yum.repos.d/
mv CentOS-Base.repo CentOS-Base.repo.bak

linuxvar=`cat /etc/issue.net |head -n1`
linuxvar=${linuxvar#*release}
linuxvar=${linuxvar:1:1}

if [ -s CentOS${linuxvar}-Base-163.repo ]; then
  echo "CentOS${linuxvar}-Base-163.repo [found]"
  else
  echo "Error: CentOS${linuxvar}-Base-163.repo not found!!!download now......"
  wget -c http://mirrors.163.com/.help/CentOS${linuxvar}-Base-163.repo
  #http://mirrors.163.com/.help/CentOS-Base-163.repo
  echo "CentOS${linuxvar}-Base-163.repo download finishing!"
fi
sleep 1
yum makecache
echo "yum download -----ok!"

#libs and tools
yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel libpcap libpcap-devel \
freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel \
bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel \
libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers \
ntp systat perl-ExtUtils-MakeMaker cmake

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
#64bit
ln -s /usr/lib64/libjpeg.so /usr/lib/
ln -s /usr/lib64/libpng.so /usr/lib/
fi

/sbin/ldconfig 

echo "setup libs and tools -----ok!"

#timezone
cat /usr/share/zoneinfo/Asia/Shanghai > /etc/localtime
cat >>/etc/sysconfig/clock<<EOF
ZONE="Asia/Shanghai" 
UTC=false 
ARC=false
EOF
echo "timezone -----ok!"


#language
cat >>/etc/sysconfig/i18n<<EOF
LANG="en_US.UTF-8"
SUPPORTED="zh_CN.UTF-8:zh_CN:zh"
SYSFONT="latarcyrheb-sun16"
EOF
#export LANG="en_US.UTF-8"
echo "language -----ok!"


#time
#yum -y install ntp
/usr/sbin/ntpdate  ntp.api.bz
/usr/sbin/ntpdate  ntp.api.bz
/usr/sbin/hwclock -w
/etc/init.d/ntpd start
chkconfig ntpd on
echo "ntpd -----ok!"

R=$(cat /etc/redhat-release)
arch=$(uname -m)