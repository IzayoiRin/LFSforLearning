# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="PythonRuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icompile(){
	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find $conf"
		return 1
	fi

    echo "Configuring ... ..."
    # prevent to use hard-coded paths to the host /usr/include and /usr/lib directories
	sed -i '/def add_multiarch_paths/a \        return' setup.py
    # ensurepip: without Python package installer
    $conf \
    --prefix=/tools \
    --without-ensurepip \
    1> /dev/null 2> $LOGS

	echo "Making ... ..."
    # compile package 
    make 1> /dev/null 2>> $LOGS

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
	echo -e "Python\n\r\tApproximate Build Time: 1.3 SBU\n\r\tSpace: 409M\n\r\tVersion: 3.8.1"
	echo ">>>>> Begin to COMPILE >>>>>"
	icompile
}


main
