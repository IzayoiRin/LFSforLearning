# !bin/bash

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="ManpagesInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    echo "Make-installing ... ..."
    # install compiled package 
    make install 1> /dev/null 2> $LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Man-pages\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 31M\n\r\tVersion: 5.05"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall
}


main
