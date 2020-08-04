# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="SedInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


clear_temp(){
    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


iinstall(){
	# Prevent two static libraries from being installed
	echo "! Disable static libraries."
	sed -i 's/usr/tools/' build-aux/help2man
	sed -i 's/testsuite.panic-tests.sh//' Makefile.in

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

	# Compile the package and generate the HTML documentation
	echo "Making ... ..." 
	make 1> /dev/null 2>> $LOGS
	make html 1> /dev/null 2>> $LOGS

	if [ "${1}" == "--test" ];then
		echo "Expect Testing ... ..."
		make check 1> /dev/null 2>>$LOGS
	fi

	# Install the package and its documentation:
	echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS
    install -d -m755 /usr/share/doc/sed-4.8
	install -m644 doc/sed.html /usr/share/doc/sed-4.8

    clear_temp
}


main(){
	echo -e "Sed\n\r\tApproximate Build Time: 0.4 SBU\n\r\tSpace: 34M\n\r\tVersion: 4.8"
	echo ">>>>> Begin to COMPILE >>>>>"
	iinstall $*
}


main $*
