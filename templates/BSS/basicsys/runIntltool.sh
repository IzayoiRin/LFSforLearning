# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="IntltoolInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    echo "! Fix warning by Perl."
    sed -i 's:\\\${:\\\$\\{:' intltool-update.in
    
    echo "Configuring ... ..."
    $conf \
    --prefix=/usr \
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
    install -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO \
    1> /dev/null 2>> $LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Intltool\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 1.5M\n\r\tVersion: 0.51.0"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
