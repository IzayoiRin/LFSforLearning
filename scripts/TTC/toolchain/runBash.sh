# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="BashRuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icompile(){
	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find $conf"
		return 1
	fi

	echo "Configuring ... ..."
	# malloc: without to use Glibc's malloc instead of Bash's malloc causing segmentation faults
	$conf \
    --prefix=/tools \
    --without-bash-malloc \
    1> /dev/null 2> $LOGS

	echo "Making ... ..."
    # compile package 
    make 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
        echo "Expect Testing ... ..."
        make tests 1> /dev/null 2>> $LOGS
    fi

    echo "Make-installing ... ..."
    # install compiled package 
    make install 1> /dev/null 2>> $LOGS
    echo "Mapping symlink ... ..."
    ln -sv bash /tools/bin/sh

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
	echo -e "Bash\n\r\tApproximate Build Time: 0.4 SBU\n\r\tSpace: 6M\n\r\tVersion: 5.0"
	echo ">>>>> Begin to COMPILE >>>>>"
	icompile $*
}


main $*
