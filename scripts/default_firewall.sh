#!/bin/bash
#########################################################################
#
# File:         default_firewall.sh
# Description:  
# Language:     GNU Bourne-Again SHell
# Version:	1.0
# Date:		2010-6-29
# Corp.:	yingjiesheng
# Author:	andychu
# WWW:		http://www.yingjiesheng.com
### END INIT INFO
###############################################################################

if [[ ! -n ${SSHPORT} ]]; then
SSHPORT=22
fi


IPTABLES=/sbin/iptables

# start by flushing the rules
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -t nat -P PREROUTING ACCEPT
$IPTABLES -t nat -P POSTROUTING ACCEPT
$IPTABLES -t nat -P OUTPUT ACCEPT
$IPTABLES -t mangle -P PREROUTING ACCEPT
$IPTABLES -t mangle -P OUTPUT ACCEPT

$IPTABLES -F
$IPTABLES -X
$IPTABLES -Z
$IPTABLES -t nat -F
$IPTABLES -t mangle -F
$IPTABLES -t nat -X
$IPTABLES -t mangle -X
$IPTABLES -t nat -Z

## allow packets coming from the machine
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A OUTPUT -o lo -j ACCEPT

# allow outgoing traffic
$IPTABLES -A OUTPUT -o eth0 -j ACCEPT

# block spoofing
$IPTABLES -A INPUT -s 127.0.0.0/8 -i ! lo -j DROP

$IPTABLES -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
$IPTABLES -A INPUT -p icmp -j ACCEPT 


# stop bad packets
#$IPTABLES -A INPUT -m state --state INVALID -j DROP

# NMAP FIN/URG/PSH
#$IPTABLES -A INPUT -i eth0 -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
# stop Xmas Tree type scanning
#$IPTABLES -A INPUT -i eth0 -p tcp --tcp-flags ALL ALL -j DROP
#$IPTABLES -A INPUT -i eth0 -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
# stop null scanning
#$IPTABLES -A INPUT -i eth0 -p tcp --tcp-flags ALL NONE -j DROP
# SYN/RST
#$IPTABLES -A INPUT -i eth0 -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
# SYN/FIN
#$IPTABLES -A INPUT -i eth0 -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
# stop sync flood
#$IPTABLES -N SYNFLOOD
#$IPTABLES -A SYNFLOOD -p tcp --syn -m limit --limit 1/s -j RETURN
#$IPTABLES -A SYNFLOOD -p tcp -j REJECT --reject-with tcp-reset
#$IPTABLES -A INPUT -p tcp -m state --state NEW -j SYNFLOOD
# stop ping flood attack
#$IPTABLES -N PING
#$IPTABLES -A PING -p icmp --icmp-type echo-request -m limit --limit 1/second -j RETURN
#$IPTABLES -A PING -p icmp -j REJECT
#$IPTABLES -I INPUT -p icmp --icmp-type echo-request -m state --state NEW -j PING


#################################
## What we allow
#################################

# tcp ports

# smtp
#$IPTABLES -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT
# http
$IPTABLES -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
# pop3
#$IPTABLES -A INPUT -p tcp -m tcp --dport 110 -j ACCEPT
# imap
#$IPTABLES -A INPUT -p tcp -m tcp --dport 143 -j ACCEPT
# ldap
#$IPTABLES -A INPUT -p tcp -m tcp --dport 389 -j ACCEPT
# https
#$IPTABLES -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
# smtp over SSL
#$IPTABLES -A INPUT -p tcp -m tcp --dport 465 -j ACCEPT
# line printer spooler
#$IPTABLES -A INPUT -p tcp -m tcp --dport 515 -j ACCEPT
# cups
#$IPTABLES -A INPUT -p tcp -m tcp --dport 631 -j ACCEPT
# mysql
$IPTABLES -A INPUT -p tcp -m tcp --dport 3306 -j ACCEPT
# tomcat
#$IPTABLES -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
# squid
#$IPTABLES -A INPUT -p tcp -m tcp --dport 81 -j ACCEPT
# nrpe
#$IPTABLES -A INPUT -p tcp -m tcp --dport 15666 -j ACCEPT

## restrict some tcp things ##

# ssh
#$IPTABLES -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp --dport ${SSHPORT} -j ACCEPT
# samba (netbios)
#$IPTABLES -A INPUT -p tcp -m tcp -s 192.168.0.0/16 --dport 137:139 -j ACCEPT
# ntop
#$IPTABLES -A INPUT -p tcp -m tcp -s 192.168.0.0/16 --dport 3000  -j ACCEPT
# Hylafax
#$IPTABLES -A INPUT -p tcp -m tcp -s 192.168.0.0/16 --dport 4558:4559 -j ACCEPT
# webmin
#$IPTABLES -A INPUT -p tcp -m tcp -s 192.168.0.0/16 --dport 10000  -j ACCEPT

# udp ports
# DNS
#$IPTABLES -A INPUT -p udp -m udp --dport 53 -j ACCEPT
# DHCP
#$IPTABLES -A INPUT -p udp -m udp --dport 67:68 -j ACCEPT
# NTP
#$IPTABLES -A INPUT -p udp -m udp --dport 123 -j ACCEPT
# SNMP
#$IPTABLES -A INPUT -p udp -m udp --dport 161:162 -j ACCEPT

## restrict some udp things ##

# Samba (Netbios)
#$IPTABLES -A INPUT -p udp -m udp -s 192.168.0.0/16 --dport 137:139  -j ACCEPT
#$IPTABLES -A INPUT -p udp -m udp --sport 137:138 -j ACCEPT

# finally - drop the rest

#$IPTABLES -A INPUT -p tcp --syn -j DROP

#save iptables
/etc/init.d/iptables save