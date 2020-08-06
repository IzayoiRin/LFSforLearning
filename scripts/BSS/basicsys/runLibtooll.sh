# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME= "LibtoolInstallLogs.log"
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
        n=$(echo ${2} || echo 4)
        echo -e "/t-cores: ${n}"
        # with multiple cores
        make check \
        TESTSUITEFLAGS=-j${n} \
        1> /dev/null 2>> $LOGS
    fi

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
    echo -e "Libtool\n\r\tApproximate Build Time: 1.8 SBU\n\r\tSpace: 43M\n\r\tVersion: 2.4.6"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
