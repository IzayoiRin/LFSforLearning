# !bin/bash

LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="{{name}}RuningtimeLogs.log"
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
	echo -e "{{name}}\n\r\tApproximate Build Time: {{sbu}}} SBU\n\r\tSpace: {{space}}\n\r\tVersion: {{ver}}"
	echo ">>>>> Begin to COMPILE >>>>>"
	icompile
}


main
