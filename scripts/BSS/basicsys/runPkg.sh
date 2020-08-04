# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="PkgconfigInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find ${conf}"
		return 1
	fi

	echo "Configuring ... ..."
	# internal: with to ust internal Glib which not available in LFS
	# host-tool: disable creation of an undesired hard link to pkg
	$conf \
	--prefix=/usr \
	--with-internal-glib \
	--disable-host-tool \
	--docdir=/usr/share/doc/pkg-config-0.29.2 \
	1> /dev/null 2> $LOGS

	# compile package 
	echo "Making ... ..."
	make 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
	    echo "Expect Testing ... ..."
	    make check 1> /dev/null 2>> $LOGS
    fi

    # install compiled package 
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
	echo -e "Pkg-config\n\r\tApproximate Build Time: 0.3 SBU\n\r\tSpace: 30M\n\r\tVersion: 0.29.2"
	echo ">>>>> Begin to COMPILE >>>>>"
	iinstall $*
}


main $*
