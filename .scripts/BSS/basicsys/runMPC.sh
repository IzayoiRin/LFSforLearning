# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="MPCInstallLogs.log"
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
    --disable-static \
    --docdir=/usr/share/doc/mpc-1.1.0 \
    1> /dev/null 2> $LOGS

    # Compile the package and generate the HTML documentation
    echo "Making ... ..."
    make 1> /dev/null 2>> $LOGS
    make html 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
        echo "Expect Testing ... ..."
        make check 1> /dev/null 2>>$LOGS
    fi

    # Install the package and its documentation
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS
    make install-html 1> /dev/null 2>> $LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}



main(){
    echo -e "MPC\n\r\tApproximate Build Time: 0.3 SBU\n\r\tSpace: 22M\n\r\tVersion: 1.1.0"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
