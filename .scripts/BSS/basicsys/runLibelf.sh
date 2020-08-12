# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="LibelfInstallLogs.log"
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
    --disable-debuginfod \
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
    make -C libelf install 1> /dev/null 2>> $LOGS
    install -m644 config/libelf.pc /usr/lib/pkgconfig \
    1> /dev/null 2>> $LOGS
    rm /usr/lib/libelf.a

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Libelf from Elfutils\n\r\tApproximate Build Time: 0.9 SBU\n\r\tSpace: 124M\n\r\tVersion: 0.178"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
