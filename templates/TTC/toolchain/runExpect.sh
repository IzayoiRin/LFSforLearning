# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="{{name}}RuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icompile(){
	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find $conf"
		return 1
	fi
	echo "Configuring ... ..."
	cp -v $conf{,.orig}
	sed 's:/usr/local/bin:/bin:' ${conf}.orig > $conf
	# tcl: Tcl location in temp tolols instead of host's
	# tclinclude: where to find Tcl's internal headers
	$conf --prefix=/tools \
		--with-tcl=/tools/lib \
		--with-tclinclude=/tools/include \
		1>/dev/null 2>$LOGS
	
	echo "Making ... ..."
    # compile package 
    make 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
        echo "Expect Testing ... ..."
        make test 1> /dev/null 2>> $LOGS
    fi

    echo "Make-installing ... ..."
    # install compiled package 
    # SCRIPTS="" prevents supple Expect scripts installing
    make SCRIPTS="" install 1> /dev/null 2>> $LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
	echo -e "{{name}}\n\r\tApproximate Build Time: {{sbu}}} SBU\n\r\tSpace: {{space}}\n\r\tVersion: {{ver}}"
	echo ">>>>> Begin to COMPILE >>>>>"
	icompile $*
}


main $*
