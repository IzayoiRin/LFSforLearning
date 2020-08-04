# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="BisonInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


itest(){
	if [ "${1}" == "--test" ];then
    	echo "! Ensure Flex has been installed."
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
	$conf \
	--prefix=/usr \
	--docdir=/usr/share/doc/bison-3.5.2 \
	1> /dev/null 2> $LOGS

	# Compile the package
	echo "Making ... ..." 
	make 1> /dev/null 2>> $LOGS

	itest $1

	# Install the package and its documentation:
	echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS

    clear_temp
}


main(){
	echo -e "Bison\n\r\tApproximate Build Time: 0.3 SBU\n\r\tSpace: 43M\n\r\tVersion: 3.5.2"
	echo ">>>>> Begin to COMPILE >>>>>"
	if [ "${1}" == "--only-test" ];then
		itest --test
		clear_temp
		return 0
	fi
	iinstall $*
}


main $*
