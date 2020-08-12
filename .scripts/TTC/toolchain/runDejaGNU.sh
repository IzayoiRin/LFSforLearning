# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="DejaGNURuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icompile(){
	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find $conf"
		return 1
	fi
	echo "Configuring ... ..."
	$conf --prefix=/tools 1> /dev/null 2> $LOGS
	
	echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
        echo "Expect Testing ... ..."
        make check 1> /dev/null 2>> $LOGS
    fi

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
	echo -e "DejaGNU\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 3.2M\n\r\tVersion: 1.6.2"
	echo ">>>>> Begin to COMPILE >>>>>"
	icompile $*
}


main $*
