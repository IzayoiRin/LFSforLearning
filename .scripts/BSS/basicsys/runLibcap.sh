# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="LibcapInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


clear_temp(){
    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


iinstall(){
    # Prevent two static libraries from being installed
    echo "! Disable static libraries."
    sed -i '/install.*STA...LIBNAME/d' libcap/Makefile
    
    # lib: sets the library directory to /lib but not /lib64 on x86_64
    echo "Making ... ..." 
    make lib=lib 1> /dev/null 2> $LOGS

    if [ "${1}" == "--test" ];then
        echo "Expect Testing ... ..."
        make test 1> /dev/null 2>>$LOGS
    fi

    # Install the package
    echo "Make-installing ... ..."
    make lib=lib install 1> /dev/null 2>> $LOGS
    chmod -v 755 /lib/libcap.so.2.31

    clear_temp
}


main(){
    echo -e "Libcap\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 8.5M\n\r\tVersion: 2.31"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
