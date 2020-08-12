# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="DiffuilsRuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icompile(){
	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find $conf"
		return 1
	fi
	echo "Configuring ... ..."
	$conf --prefix=/tools 1> /dev/null 2> $LOGS

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
	echo -e "Diffuils\n\r\tApproximate Build Time: 0.2 SBU\n\r\tSpace: 26M\n\r\tVersion: 3.7"
	echo ">>>>> Begin to COMPILE >>>>>"
	icompile $*
}


main $*
