# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="KmodInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    echo "Configuring ... ..."
    # xz,zilb: with to handle compressed kernel modules.
    # rootlibdir: with to ensures different library related files are placed in the correct directories.
    $conf \
    --prefix=/usr \
    --bindir=/bin \
    --sysconfdir=/etc \
    --with-rootlibdir=/lib \
    --with-xz \
    --with-zlib \
    1> /dev/null 2> $LOGS

    # compile package 
    echo "Making ... ..."
    make 1> /dev/null 2>> $LOGS

    # install compiled package 
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS

    for target in depmod insmod lsmod modinfo modprobe rmmod; do
        ln -sfv ../bin/kmod /sbin/$target
    done
    ln -sfv kmod /bin/lsmod

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Kmod-26\n\r\tApproximate Build Time: 0.1 SBU\n\r\tSpace: 13M\n\r\tVersion: 26"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall
}


main
