# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="AclInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


itest(){
	if [ "${1}" == "--test" ];then
    	echo "! Ensure Coreutils has been installed."
    	# run on a filesystem such as the ext2, ext3, or ext4 
	    echo "Expect Testing ... ..."
	    make check 1> /dev/null 2>> $LOGS
    fi
}


clear_temp(){
	echo "Cleaning Temps ... ..."
	dir=`pwd`;cd ../
	echo "remove ${dir}"
	rm -rf $dir
	pwd
}


iinstall(){
	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find ${conf}"
		return 1
	fi

	echo "Configuring ... ..."
	$conf --prefix=/usr \
	--bindir=/bin \
	--disable-static \
	--libexecdir=/usr/lib \
	--docdir=/usr/share/doc/acl-2.2.53 \
	1> /dev/null 2> $LOGS

	# compile package 
	echo "Making ... ..."
	make 1> /dev/null 2>> $LOGS

	itest $1

    echo "Make-installing ... ..."
    # install compiled package 
    make install 1> /dev/null 2>> $LOGS
    # shared lib moved to /lib and recreate .so file in /usr/lib
    echo "move: /usr/lib/libacl.so.* ---> /lib"
	mv /usr/lib/libacl.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so

	clear_temp
}



main(){
	echo -e "Acl\n\r\tApproximate Build Time: 0.1 SBU\n\r\tSpace: 6.4M\n\r\tVersion: 2.2.53"
	echo ">>>>> Begin to COMPILE >>>>>"
	if [ "${1}" == "--only-test" ];then
		itest --test
		clear_temp
		return 0
	fi
	iinstall $*
}


main $*
