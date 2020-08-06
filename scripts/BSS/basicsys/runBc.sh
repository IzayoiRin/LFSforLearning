# !bin/bash

CONFIGURE_FILE="configure.sh"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="BcInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    echo "Configuring ... ..."
    # CC,CFLAGS: specify the compiler and C standard to use.
    # O3: optimization to use.
    # G: Omit parts of the test suite that won't work without a GNU bc present
    PREFIX=/usr CC=gcc CFLAGS="-std=c99" $conf -G -O3 \
    1> /dev/null 2> $LOGS

    echo "Making ... ..."
    # compile package 
    make 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
        echo "Expect Testing ... ..."
        make test 1> /dev/null 2>> $LOGS
    fi

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
    echo -e "Bc\n\r\tApproximate Build Time: 0.1 SBU\n\r\tSpace: 2.9M\n\r\tVersion: 2.5.3"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
