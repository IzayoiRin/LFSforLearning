# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="FileInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find ${conf}"
		return 1
	fi

	echo "Configuring ... ..."
	$conf --prefix=/usr 1> /dev/null 2> $LOGS

	echo "Making ... ..."
	# compile package 
	make 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
	    echo "Expect Testing ... ..."
	    make check 1> /dev/null 2>> $LOGS
    fi

    echo "Make-installing ... ..."
    # install compiled package 
    make install 1> /dev/null 2>> $LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
	echo -e "File\n\r\tApproximate Build Time: 0.1 SBU\n\r\tSpace: 20M\n\r\tVersion: 5.38"
	echo ">>>>> Begin to COMPILE >>>>>"
	iinstall $*
}


main $*
