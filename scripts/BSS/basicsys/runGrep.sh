# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="GrepInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


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
	--bindir=/bin \
	1> /dev/null 2> $LOGS

	# Compile the package
	echo "Making ... ..." 
	make 1> /dev/null 2>> $LOGS

	if [ "${1}" == "--test" ];then
		echo "Expect Testing ... ..."
		make check 1> /dev/null 2>>$LOGS
	fi

	# Install the package
	echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS

    clear_temp
}


main(){
	echo -e "Grep\n\r\tApproximate Build Time: 0.7 SBU\n\r\tSpace: 39M\n\r\tVersion: 3.4"
	echo ">>>>> Begin to COMPILE >>>>>"
	iinstall $*
}


main $*
