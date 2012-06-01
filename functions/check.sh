check_file(){
	if [ "$1" ]; then
		local file=$1
	fi
	if [ "$2" ]; then
		local url=$2
	fi
	if [ -s $file ]; then
		echo "$file [found]"
		else
		echo "Error: $file not found!!!download now......"
		wget -c $url
		echo "$file download finishing!"
		if [ ! -s $file ]; then
			echo "$file still not found,please check it!"
			exit 1;
		fi
	fi
}

check_install(){
	if [ "$1" ]; then
		local dirname=$1
	fi
	if [ "$2" ]; then
		local funcname=$2
	fi
	local REQ=''
	if [ -d $dirname ]; then
		read -p "Note: $dirname may be installed,do you want re-install?(y/n)" REQ
		case "$REQ" in
		y|Y)
			cd $dirname
			make clean
			cd ..
			/bin/rm -rf $dirname
			install_$funcname
			return 0
			;;
		*)
			#exit 0
			;;
		esac
	else
	install_$funcname
	cd ..
	return 0
	fi
}
