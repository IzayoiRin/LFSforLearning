# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="InetutilsInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    echo "Configuring ... ..."
    # logger: disable installing logger.
    # r*: disable installing obsolete due to security.
    # servers: disable installing network servers.
    $conf \
    --prefix=/usr \
    --localstatedir=/var \
    --disable-logger \
    --disable-rcp \
    --disable-rexec \
    --disable-rlogin \
    --disable-rsh \
    --disable-servers \
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

    # available if /usr is not accessible
    mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
    mv -v /usr/bin/ifconfig /sbin

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Inetutils\n\r\tApproximate Build Time: 0.3 SBU\n\r\tSpace: 29M\n\r\tVersion: 1.9.4"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
