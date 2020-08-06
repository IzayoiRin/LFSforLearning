# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="GroffInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    echo "Configuring ... ..."
    psize=$(echo ${1} || echo 4)
    PAGE=${psize} $conf \
    --prefix=/usr \
    1> /dev/null 2> $LOGS

    # compile package 
    echo "Making ... ..."
    make -j1 1> /dev/null 2>> $LOGS

    # install compiled package 
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS

    mv -v /usr/bin/find /bin
    sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Groff\n\r\tApproximate Build Time: 0.5 SBU\n\r\tSpace: 95M\n\r\tVersion: 1.22.4"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $1
}


main $*
