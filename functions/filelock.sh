#!/bin/bash
#########################################################################
#
###############################################################################


# we need root to run 
if test "`id -u`" -ne 0
then
	echo "You need to start as root!"
	exit
fi

case $1 in

	"lock")
		echo "lock user&services ..."
		echo "chattr +i /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/services"
		chattr +i /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/services
		;;

	"unlock")
		echo "unlock user&services ..."
		echo "chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/services"
		chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/services
		;;
	*)	
		echo "Usage: $0 <action>"
		echo ""
		echo "	lock        lock user&services"
		echo "	unlock      unlock user&services"
		echo ""

		;;
esac
