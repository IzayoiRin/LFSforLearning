# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="PsmiscInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


clear_temp(){
    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


iinstall(){
    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    echo "Configuring ... ..."
    $conf \
    --prefix=/usr \
    1> /dev/null 2> $LOGS

    # Compile the package
    echo "Making ... ..." 
    make 1> /dev/null 2>> $LOGS

    # Install the package
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS

    echo "! Move <killall>&<fuser> for LFS."
    mv -v /usr/bin/fuser /bin
    mv -v /usr/bin/killall /bin
    
    clear_temp
}


main(){
    echo -e "Psmisc\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 4.6M\n\r\tVersion: 23.2"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall
}


main 
