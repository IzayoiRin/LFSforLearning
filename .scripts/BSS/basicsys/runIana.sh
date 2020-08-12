# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="Iana-EtcInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


clear_temp(){
    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


iinstall(){
    echo "Making ... ..." 
    make 1> /dev/null 2> $LOGS

    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS
}


main(){
    echo -e "Iana-Etc\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 2.3M\n\r\tVersion: 2.30"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall
}


main
