# !bin/bash

CONFIGURE_FILE="configure"
SUPPORT_PACK="udev-lfs-20171102.tar.xz"

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="EudevInstallLogs.log"
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
    --sbindir=/sbin \
    --libdir=/usr/lib \
    --sysconfdir=/etc \
    --libexecdir=/lib \
    --with-rootprefix= \
    --with-rootlibdir=/lib \
    --enable-manpages \
    --disable-static \
    1> /dev/null 2> $LOGS

    # compile package 
    echo "Making ... ..."
    make 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
        echo "! Create directories needed for tests."
        mkdir -pv /lib/udev/rules.d
        mkdir -pv /etc/udev/rules.d
        echo "Expect Testing ... ..."
        make check 1> /dev/null 2>> $LOGS
    fi

    # install compiled package 
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS

    echo "Install some custom rules and support files ... ..."
    
    supr="../${SUPPORT_PACK}"
    if [ ! -f $supr ];then
        echo "Can't find ${supr}"
        return 1
    fi

    make -f $supr install 1> /dev/null 2>> $LOGS

    udevadm hwdb --update

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Eudev\n\r\tApproximate Build Time: 0.2 SBU\n\r\tSpace: 83M\n\r\tVersion: 3.2.9"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
