# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="GperfInstallLogs.log"
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
    --docdir=/usr/share/doc/gperf-3.1 \
    1> /dev/null 2> $LOGS

    # compile package 
    echo "Making ... ..."
    make 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
        echo "Expect Testing ... ..."
        n=1;if [ $2 ];then n=${2};fi
        echo -e "/t-cores: ${n}"
        # with multiple cores causing failed test
        make -j${n} check \
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
    echo -e "Gperf\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 6.3M\n\r\tVersion: 3.1"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
