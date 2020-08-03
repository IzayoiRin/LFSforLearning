# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="MPFRInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find ${conf}"
		return 1
	fi

	echo "Configuring ... ..."
	$conf \
	--prefix=/usr \
	--enable-thread-safe \
	--disable-static \
	--docdir=/usr/share/doc/mpfr-4.0.2 \
	1> /dev/null 2> $LOGS

	# Compile the package and generate the HTML documentation
	echo "Making ... ..."
	make 1> /dev/null 2>> $LOGS
	make html 1> /dev/null 2>> $LOGS

	# critical necessary test, do not skip
	echo "Expect Testing ... ..."
	make check 1> /dev/null 2>>$LOGS

	# Install the package and its documentation
	echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS
    make install-html 1> /dev/null 2>> $LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}



main(){
	echo -e "MPFR\n\r\tApproximate Build Time: 0.8 SBU\n\r\tSpace: 37M\n\r\tVersion: 4.0.2"
	echo ">>>>> Begin to COMPILE >>>>>"
	iinstall $*
}


main