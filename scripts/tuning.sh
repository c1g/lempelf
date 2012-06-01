#!/bin/bash

#turning system
ulimit -HSn 51200
if grep "#\[lempelf\]" "/etc/security/limits.conf" > /dev/null; then
echo "Note:limits.conf skip! "
else
echo -ne "
#[lempelf]
* soft nofile 51200
* hard nofile 51200
" >>/etc/security/limits.conf
echo "limits.conf -----ok!"
fi

if grep "ulimit" "/etc/rc.local" > /dev/null; then
echo "Note:ulimit skip! "
else
echo "ulimit -HSn 51200" >> /etc/rc.local
echo "ulimit -----ok!"
fi


#/etc/sysctl.conf
if grep "#\[lempelf\]" "/etc/sysctl.conf" > /dev/null; then
echo "Note:sysctl.conf skip! "
else

linuxvar=`cat /etc/issue.net |head -n1`
linuxvar=${linuxvar#*release}
linuxvar=${linuxvar:1:1}

if uname -m | grep "x86_64" > /dev/null; then
archvalue=2
else
archvalue=1
fi
ramsize=`grep "MemTotal" "/proc/meminfo" |awk  '{ print $2 }'`

#conntrack_max=hashsize*8
#hashsize=conntrack_max/8=ramsize(in bytes)/131072/(x/32)
conntrack_max=$[ ${ramsize} * 1024 / 131072 / ${archvalue} * 8 ]
shmmax=$[ ${ramsize} *102 * 8 ]

if [ ${linuxvar} = 6 ]; then
cat >>/etc/sysctl.conf<<EOF
#[lempelf]
net.nf_conntrack_max =  ${conntrack_max} 
net.netfilter.nf_conntrack_tcp_timeout_established = 36000
EOF
else
cat >>/etc/sysctl.conf<<EOF
#[lempelf]
net.ipv4.netfilter.ip_conntrack_max = ${conntrack_max} # 64bit4G=131072,64bit8G=262144
net.ipv4.netfilter.ip_conntrack_tcp_timeout_established = 36000
EOF
fi

cat >>/etc/sysctl.conf<<EOF

net.ipv4.tcp_max_tw_buckets = 35000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_wmem = 4096        16384   4194304

net.ipv4.tcp_max_syn_backlog = 65536
net.core.netdev_max_backlog =  32768
net.core.somaxconn = 32768

net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2

net.ipv4.tcp_tw_recycle = 1
#net.ipv4.tcp_tw_len = 1
net.ipv4.tcp_tw_reuse = 1

net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800

#net.ipv4.tcp_fin_timeout = 30

#net.ipv4.tcp_keepalive_time = 300
net.ipv4.ip_local_port_range = 1024    65000

kernel.shmmax=${shmmax}

EOF
/sbin/sysctl -p /etc/sysctl.conf
echo "sysctl.conf -----ok!"
fi
