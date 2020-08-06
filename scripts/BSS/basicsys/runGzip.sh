# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="GzipInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


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

    # compile package 
    echo "Making ... ..."
    make 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
        echo "Expect Testing ... ..."
        make check 1> /dev/null 2>> $LOGS
    fi

    # install compiled package 
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS
    mv -v /usr/bin/gzip /bin

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Gzip\n\r\tApproximate Build Time: 0.1 SBU\n\r\tSpace: 20M\n\r\tVersion: 1.10"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $1
}


main $*
