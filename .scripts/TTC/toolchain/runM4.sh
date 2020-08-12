# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="M4RuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icompile(){
	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find $conf"
		return 1
	fi

	echo "! Fix problems introduced by Glibc-2.31"
	sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
	echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
	
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
	echo -e "M4\n\r\tApproximate Build Time: 0.2 SBU\n\r\tSpace: 20M\n\r\tVersion: 1.4.18"
	echo ">>>>> Begin to COMPILE >>>>>"
	icompile $*
}


main $*