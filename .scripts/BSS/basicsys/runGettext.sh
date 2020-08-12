# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="GettextInstallLogs.log"
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
    --disable-static \
    --docdir=/usr/share/doc/gettext-0.20.1 \
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
    chmod -v 0755 /usr/lib/preloadable_libintl.so

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Gettext\n\r\tApproximate Build Time: 2.7 SBU\n\r\tSpace: 249M\n\r\tVersion: 0.20.1"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
