# !bin/bash

LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="LinuxAPIRuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icompile(){
	echo "Ensuring no stale files" 
	make mrproper 1>/dev/null 2>$LOGS
	echo "Extracting user-visible kernel headers"
	make headers 1>/dev/null 2>>$LOGS
	echo "copy: usr/include/* ---> /tools/include"
	cp -r usr/include/* /tools/include 1>/dev/null 2>>$LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
	echo -e "LinuxAPI\n\r\tApproximate Build Time: 0.1 SBU\n\r\tSpace: 1G\n\r\tVersion: 5.5.3"
	echo ">>>>> Begin to COMPILE >>>>>"
	icompile
}


main
