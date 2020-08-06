# !bin/bash

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="MesonInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    echo "Making ... ..." 
    python3 setup.py build 1>/dev/null 2>$LOGS
    
    echo "Make-installing ... ..."
    python3 setup.py install --root=dest \
    1>/dev/null 2>>$LOGS
    cp -r dest/* /

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Meson\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 31M\n\r\tVersion: 0.53.1"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall
}


main
