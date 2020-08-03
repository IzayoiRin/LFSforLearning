# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="AttrInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


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
	--sysconfdir=/etc \
	--docdir=/usr/share/doc/attr-2.4.48 \
	1> /dev/null 2> $LOGS

	# compile package 
	echo "Making ... ..."
	make 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
    	# run on a filesystem such as the ext2, ext3, or ext4 
	    echo "Expect Testing ... ..."
	    make check 1> /dev/null 2>> $LOGS
    fi

    echo "Make-installing ... ..."
    # install compiled package 
    make install 1> /dev/null 2>> $LOGS
    # shared lib moved to /lib and recreate .so file in /usr/lib
    echo "move: /usr/lib/libattr.so.* ---> /lib"
	mv /usr/lib/libattr.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}



main(){
	echo -e "Attr\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 4.2M\n\r\tVersion: 2.4.48"
	echo ">>>>> Begin to COMPILE >>>>>"
	iinstall $*
}


main $*
