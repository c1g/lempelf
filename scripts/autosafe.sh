#!/bin/bash
#########################################################################
#
# File:         autosafe.sh
# Description:  
# Language:     GNU Bourne-Again SHell
# Version:	1.3
# Date:		2012-3-29
# Author:	c1g
# WWW:		http://blog.c1gstudio.com
### END INIT INFO
###############################################################################

if [[ ! -n ${WORKUSER} ]]; then
WORKUSER=andychu
fi
if [[ ! -n ${SSHPORT} ]]; then
SSHPORT=22
fi
V_DELUSER="adm lp sync shutdown halt mail news uucp operator games gopher ftp"
V_DELGROUP="adm lp mail news uucp games gopher mailnull floppy dip pppusers popusers slipusers daemon"
V_PASSMINLEN=8
V_HISTSIZE=30
V_TMOUT=300
V_GROUPNAME=suadmin
#V_SERVICE Not working since Version 1.2
#V_SERVICE="acpid anacron apmd atd auditd autofs avahi-daemon avahi-dnsconfd bluetooth cpuspeed cups dhcpd firstboot gpm haldaemon hidd ip6tables ipsec isdn kudzu lpd mcstrans microcode_ctl netfs nfs nfslock nscd pcscd portmap readahead_early restorecond rpcgssd rpcidmapd rstatd sendmail postfix setroubleshoot snmpd  xfs xinetd yppasswdd ypserv yum-updatesd tog-pegasus"
V_TTY="3|4|5|6"
V_SUID=(
	'/usr/bin/chage' 
	'/usr/bin/gpasswd' 
	'/usr/bin/wall' 
	'/usr/bin/chfn' 
	'/usr/bin/chsh' 
	'/usr/bin/newgrp'
	'/usr/bin/write' 
	'/usr/sbin/usernetctl' 
	'/bin/traceroute' 
	'/bin/mount'
	'/bin/umount' 
	'/sbin/netreport' 
)
linuxvar=`cat /etc/issue.net |head -n1`
linuxvar=${linuxvar#*release}
linuxvar=${linuxvar:1:1}
version=1.3


# we need root to run 
if test "`id -u`" -ne 0
then
	echo "You need to start as root!"
	exit
fi

safe_deluser(){
		 echo "delete user ..."
		 for i in $V_DELUSER ;do 
		 echo "deleting $i";
		 userdel $i ;
		 done
}

safe_delgroup(){
		 echo "delete group ..."
		 for i in $V_DELGROUP ;do 
		 echo "deleting $i";
		 groupdel $i;
		 done
}

safe_password(){
		 echo "change password limit ..."
		 echo "/etc/login.defs"
		 echo "PASS_MIN_LEN $V_PASSMINLEN"
		 sed -i "/^PASS_MIN_LEN/s/5/$V_PASSMINLEN/" /etc/login.defs 
}

safe_history(){
		 echo "change history limit ..."
		 echo "/etc/profile"
		 echo "HISTSIZE $V_HISTSIZE"
		 sed -i "/^HISTSIZE/s/1000/$V_HISTSIZE/" /etc/profile 
}

safe_logintimeout(){
		 echo "change login timeout ..."
		 echo "/etc/profile"
		 echo "TMOUT=$V_TMOUT"
		 sed -i "/^HISTSIZE/a\TMOUT=$V_TMOUT" /etc/profile 
}

safe_bashhistory(){
		echo "denied bashhistory ..."
		echo "/etc/skel/.bash_logout"
		echo 'rm -f $HOME/.bash_history'
		if egrep "bash_history" /etc/skel/.bash_logout > /dev/null
		then
			echo 'warning:existed'
		else
		 echo 'rm -f $HOME/.bash_history' >> /etc/skel/.bash_logout 
		fi

}
safe_mysqlhistory(){
		echo "denied mysql_history ..."
		echo "/root/.mysql_history"
		echo "rm -f /root/.mysql_history"
		echo "ln -s /dev/null /root/.mysql_history"
		if [ -h /root/.mysql_history ] ; 
		then
			echo 'warning:existed'
		else
			rm -f /root/.mysql_history
			ln -s /dev/null  /root/.mysql_history
		fi
		echo "/home/${WORKUSER}/.mysql_history"
		echo "rm -f /home/${WORKUSER}/.mysql_history"
		echo "ln -s /dev/null /home/${WORKUSER}/.mysql_history"
		if [ -h /home/${WORKUSER}/.mysql_history ] ; 
		then
			echo 'warning:existed'
		else
			rm -f /home/${WORKUSER}/.mysql_history
			ln -s /dev/null /home/${WORKUSER}/.mysql_history
		fi

}

safe_addgroup(){
		echo "groupadd $V_GROUPNAME ..."
		groupadd $V_GROUPNAME
}

safe_sugroup(){
		echo "permit $V_GROUPNAME use su ..."
		echo "/etc/pam.d/su"
		echo "auth	sufficient	pam_rootok.so	debug"
		echo "auth	required	pam_wheel.so	group=$V_GROUPNAME"
		echo "gpasswd -a $WORKUSER $V_GROUPNAME"
		if egrep "auth	required	pam_wheel.so" /etc/pam.d/su > /dev/null
		then
			echo 'warning:existed'
		else
			sed -i "/^#%PAM/a\auth	required	pam_wheel.so	group=${V_GROUPNAME}" /etc/pam.d/su 
			sed -i "/^#%PAM/a\auth	sufficient	pam_rootok.so	debug" /etc/pam.d/su 
			gpasswd -a $WORKUSER $V_GROUPNAME
		fi
}

safe_sudoer(){
		echo "permit $WORKUSER use sudo ..."
		echo "/etc/sudoers"
		echo "$WORKUSER ALL=(ALL)       ALL" 
		if [  -n $WORKUSER ]
		then
			if egrep "$WORKUSER" /etc/sudoers > /dev/null
			then
				echo "warning:existed! "
			else
				echo "$WORKUSER ALL=(ALL)       ALL" >> /etc/sudoers
				echo 'export PATH=$PATH:/sbin:/usr/sbin' >> /etc/bashrc
				echo 'export LDFLAGS="-L/usr/local/lib -Wl,-rpath,/usr/local/lib"' >> /etc/bashrc
				echo 'export LD_LIBRARY_PATH="/usr/local/lib"' >> /etc/bashrc
			fi
		else
			echo "warning:skip! "
		fi
}

safe_denyrootssh(){
		echo "denied root login ..."
		echo "/etc/ssh/sshd_config"
		echo "PermitRootLogin no"
		sed -i '/^#PermitRootLogin/s/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config 
		sed -i '/^#UseDNS yes/s/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config 
}

safe_changesshport(){
		echo "change ssh port ..."
		echo "/etc/ssh/sshd_config"
		echo "Port $SSHPORT"
		if egrep "Port $SSHPORT" /etc/ssh/sshd_config > /dev/null
		then
			echo "warning:existed! "
		else
			echo "Port $SSHPORT" >> "/etc/ssh/sshd_config"
		fi
}

safe_stopservice(){
		echo "stop services ..."
			for i in $V_SERVICE ;do 
			service $i stop;
			done
}

safe_closeservice(){
		echo "close services autostart ..."
			for i in $V_SERVICE ;do
			chkconfig $i off;
			done
}

safe_closeservicewhite(){
		echo "close services autostart ..."
		for i in `ls /etc/rc3.d/S*`
		do
			CURSRV=`echo $i|cut -c 15-`
			echo $CURSRV
			case $CURSRV in
				 crond | irqbalance | microcode_ctl | network | sshd | syslog | rsyslog | snmpd | fail2ban | ntpd | lvm2-monitor | iptables | auditd | kdump | sysstat | memcached | smartd | nagios | local | sphinx )
			     ;;
			     *)
				 echo "change $CURSRV to off"
				 chkconfig --level 235 $CURSRV off
				 service $CURSRV stop
			     ;;
			esac
		done
}

safe_tty(){
		echo "close tty ..."
		if [ ${linuxvar} == 6 ]; then
			echo "/etc/init/start-ttys.conf"
			echo "/etc/sysconfig/init"
			echo "ACTIVE_CONSOLES=/dev/tty[${V_TTY6}]"
			echo "init q"
			#close tty
			#initctl stop tty TTY=/dev/tty6
			sed -i "/^env ACTIVE_CONSOLES/s/\[1-6\]/\[${V_TTY6}\]/" /etc/init/start-ttys.conf
			sed -i "/^ACTIVE_CONSOLES/s/\[1-6\]/\[1-2\]/" /etc/sysconfig/init 

		else
			echo "/etc/inittab"
			echo "#3:2345:respawn:/sbin/mingetty tty3"
			echo "#4:2345:respawn:/sbin/mingetty tty4"
			echo "#5:2345:respawn:/sbin/mingetty tty5"
			echo "#6:2345:respawn:/sbin/mingetty tty6"
			sed -i "/^[${V_TTY}]:2345/s/^/#/" /etc/inittab
			echo "init q"
		fi
		init q
}

safe_ctrlaltdel(){
		echo "close ctrl+alt+del to restart server ..."
		if [ ${linuxvar} == 6 ]; then
			echo "/etc/init/control-alt-delete.conf"
			echo '#exec /sbin/shutdown -r now "Control-Alt-Delete pressed"'
			echo "init q"
			sed -i '/^exec/s/^/#/' /etc/init/control-alt-delete.conf
		else
			echo "/etc/inittab"
			echo "#ca::ctrlaltdel:/sbin/shutdown -t3 -r now"
			echo "init q"
			sed -i '/^ca::/s/^/#/' /etc/inittab
		fi
		init q
}

safe_ipv6(){
		echo "close ipv6 ..."
		if [ ${linuxvar} == 6 ]; then
			echo '"alias net-pf-10 off" >> /etc/modprobe.d/ipv6.conf'
			echo '"options ipv6 disable=1" >> /etc/modprobe.d/ipv6.conf'

cat > /etc/modprobe.d/ipv6.conf << EOF
alias net-pf-10 off
options ipv6 disable=1
EOF
		else
			echo '"alias net-pf-10 off" >> /etc/modprobe.conf'
			echo '"alias ipv6 off" >> /etc/modprobe.conf'
			if egrep "alias net-pf-10 off" /etc/modprobe.conf > /dev/null
			then
				echo "warning:existed! "
			else
				echo "alias net-pf-10 off" >> /etc/modprobe.conf
				echo "alias ipv6 off" >> /etc/modprobe.conf
			fi

		fi
		echo '/sbin/chkconfig ip6tables off'
		echo '"NETWORKING_IPV6=no" >> /etc/sysconfig/network'
		/sbin/chkconfig --level 35 ip6tables off
		if egrep "NETWORKING_IPV6=no" /etc/sysconfig/network > /dev/null
		then
			echo "warning:existed! "
		else
			echo "NETWORKING_IPV6=no" >> /etc/sysconfig/network
		fi
}

safe_selinux(){
		echo "disable selinux ..."
		echo "sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config "
		sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config 
		echo "selinux is disabled,you must reboot!"
}

safe_vim(){
		echo "edit vim ..."
		#echo "alias vi='vim'"
		#sed -i "8 s/^/alias vi='vim'/" /root/.bashrc
cat >/root/.vimrc<<EOF
syntax on
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
EOF
}

safe_lockfile(){
		echo "lock user&services ..."
		echo "chattr +i /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/services"
		chattr +i /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/services
}

safe_unlockfile(){
		echo "unlock user&services ..."
		echo "chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/services"
		chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/services
}

safe_chmodinit(){
		echo "init script only for root ..."
		echo "chmod -R 700 /etc/init.d/*"
		echo "chmod 600 /etc/grub.conf"
		echo "chattr +i /etc/grub.conf"
		chmod -R 700 /etc/init.d/*
		chmod 600 /etc/grub.conf 
		chattr +i /etc/grub.conf
}

safe_chmodcommand(){
		echo "remove SUID ..."
		echo "/usr/bin/chage /usr/bin/gpasswd ..."
		for i in ${V_SUID[@]};
		do
			chmod a-s $i
		done
}


safe_deluser
safe_delgroup
safe_password 
safe_history
safe_logintimeout
safe_bashhistory
safe_mysqlhistory
safe_addgroup
safe_sugroup
safe_sudoer
safe_denyrootssh
safe_changesshport
#safe_stopservice 
#safe_closeservice
safe_closeservicewhite
safe_tty
safe_ctrlaltdel
safe_ipv6
safe_selinux
safe_vim
safe_lockfile
safe_chmodinit
safe_chmodcommand

#safe_unlockfile
