# !bin/bash

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="LinuxAPIInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    echo "Ensuring no stale files" 
    make mrproper 1>/dev/null 2>$LOGS
    echo "Extracting user-visible kernel headers"
    make headers 1>/dev/null 2>>$LOGS
    # headers_instal cannot used cause rysnc not available in /tools
    find usr/include -name '.*' -delete
    rm usr/include/Makefile
    echo "copy: usr/include/* ---> /usr/include"
    cp -r usr/include/* /usr/include 1>/dev/null 2>>$LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "LinuxAPI\n\r\tApproximate Build Time: 0.1 SBU\n\r\tSpace: 1G\n\r\tVersion: 5.5.3"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall
}


main
