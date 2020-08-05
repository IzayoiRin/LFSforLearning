# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="FlexInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


clear_temp(){
    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


iinstall(){
	echo "! Fix a problem cause by glibc."
	sed -i "/math.h/a #include <malloc.h>" src/flexdef.h

	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find ${conf}"
		return 1
	fi

	echo "Configuring ... ..."
	# help2man program is available to create a man page which is not present using env variable to skip.
	HELP2MAN=/tools/bin/true \
	$conf \
	--prefix=/usr \
	--docdir=/usr/share/doc/flex-2.6.4 \
	1> /dev/null 2> $LOGS

	# Compile the package
	make 1> /dev/null 2>> $LOGS

	if [ "${1}" == "--test" ];then
		echo "Expect Testing ... ..."
		make check 1> /dev/null 2>>$LOGS
	fi

	# Install the package
	echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS
    # create a symbolic link named lex that runs flex in lex emulation mode
    ln -sv flex /usr/bin/lex
    clear_temp
}


main(){
	echo -e "Flex\n\r\tApproximate Build Time: 0.4 SBU\n\r\tSpace: 36M\n\r\tVersion: 2.6.4"
	echo ">>>>> Begin to COMPILE >>>>>"
	iinstall $*
}


main $*
