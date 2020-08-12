# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="ExpatInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    echo "Fix a problem in LFS env"
    sed -i 's|usr/bin/env |bin/|' run.sh.in

    echo "Configuring ... ..."
    $conf \
    --prefix=/usr \
    --disable-static \
    --docdir=/usr/share/doc/expat-2.2.9 \
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

    echo "Install documentation ... ..."
    install -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.9 \
    1> /dev/null 2>> $LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Expat\n\r\tApproximate Build Time: 0.1 SBU\n\r\tSpace: 11M\n\r\tVersion: 2.2.9"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
