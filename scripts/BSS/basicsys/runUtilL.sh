# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="Util-linuxInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi
    echo"! Create a directory to enable storage for the hwclock."
    mkdir -pv /var/lib/hwclock

    echo "Configuring ... ..."
    $conf \
    ADJTIME_PATH=/var/lib/hwclock/adjtime \
    --docdir=/usr/share/doc/util-linux-2.35.1 \
    --disable-chfn-chsh \
    --disable-login \
    --disable-nologin \
    --disable-su \
    --disable-setpriv \
    --disable-runuser \
    --disable-pylibmount \
    --disable-static \
    --without-python \
    --without-systemd \
    --without-systemdsystemunitdir \
    1> /dev/null 2> $LOGS

    # compile package 
    echo "Making ... ..."
    make 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
        echo "Expect Testing ... ..."
        echo "change ownership: nobody <<< ."
        chown -R nobody .
        su nobody -s /bin/bash -c "PATH=$PATH make -k check" \
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
    echo -e "Util-linux\n\r\tApproximate Build Time: 1.1 SBU\n\r\tSpace: 289M\n\r\tVersion: 2.35.1"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $1
}


main $*
