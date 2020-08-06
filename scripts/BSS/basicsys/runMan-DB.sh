# !/bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="Man-DBInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    echo "Configuring ... ..."
    # libgdbm: enable with libgdbm compatibility library to provide older DBM 
    $conf \
    --prefix=/usr \
    --docdir=/usr/share/doc/man-db-2.9.0 \
    --sysconfdir=/etc \
    --disable-setuid \
    --enable-cache-owner=bin \
    --with-browser=/usr/bin/lynx \
    --with-vgrind=/usr/bin/vgrind \
    --with-grap=/usr/bin/grap \
    --with-systemdtmpfilesdir= \
    --with-systemdsystemunitdir= \
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

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Man-DB\n\r\tApproximate Build Time: 0.5 SBU\n\r\tSpace: 40M\n\r\tVersion: 2.9.0"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
