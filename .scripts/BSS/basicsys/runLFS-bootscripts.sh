# !bin/bash

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="LFS-BootscriptsInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    # install compiled package 
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "LFS-Bootscripts\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 224k\n\r\tVersion: 20191031"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall
}


main
