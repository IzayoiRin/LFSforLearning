# !bin/bash

PATCH_FILE="sysvinit-2.96-consolidated-1.patch"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="SysvinitInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    pch="../${PATCH_FILE}"
    if [ ! -f $pch ];then
        echo "Can't find ${pch}"
        return 1
    fi
    echo "Patch Self ... ..."
    # install the documentation
    patch -Np1 -i $pch 1> /dev/null 2> $LOGS

    echo "Making ... ..."
    # compile package 
    make 1> /dev/null 2>> $LOGS

    echo "Make-installing ... ..."
    # install compiled package 
    make install 1> /dev/null 2>> $LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Sysvinit\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 1.4M\n\r\tVersion: 2.96"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall
}


main
