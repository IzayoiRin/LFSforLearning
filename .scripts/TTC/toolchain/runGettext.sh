# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="GettextRuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icompile(){
	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find $conf"
		return 1
	fi
	echo "Configuring ... ..."
	# share: disable cause not need to install shared lib
	$conf --disable-shared 1> /dev/null 2>> $LOGS

	echo "Making ... ..."
    # compile package 
    make 1> /dev/null 2>> $LOGS

    echo "Installing ... ..."
    # Install the msgfmt, msgmerge and xgettext programs
    cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /tools/bin

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
	echo -e "Gettext\n\r\tApproximate Build Time: 1.6 SBU\n\r\tSpace: 300M\n\r\tVersion: 0.20.1"
	echo ">>>>> Begin to COMPILE >>>>>"
	icompile 
}


main 
