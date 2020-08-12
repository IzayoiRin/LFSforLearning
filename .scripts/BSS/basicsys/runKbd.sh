# !/bin/bash

CONFIGURE_FILE="configure"
PATCH_FILE="kbd-2.2.0-backspace-1.patch"

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="KbdInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


clear_temp(){
    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


iinstall(){
    pch="../${PATCH_FILE}"
    if [ ! -f $pch ];then
        echo "Can't find ${pch}"
        return 1
    fi
    echo "Patch Self ... ..."
    # install the documentation
    patch -Np1 -i $pch 1> /dev/null 2> $LOGS

    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    echo "! Remove the redundant resizecons program."
    sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
    sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
    
    # readline: with readline lib instead of its own version
    echo "Configuring ... ..."
    PKG_CONFIG_PATH=/tools/lib/pkgconfig \
    $conf \
    --prefix=/usr \
    --disable-vlock \
    1> /dev/null 2>> $LOGS
    
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
    mkdir -v /usr/share/doc/kbd-2.2.0
    cp -R docs/doc/* /usr/share/doc/kbd-2.2.0
    
    clear_temp
}


main(){
    echo -e "Kbd\n\r\tApproximate Build Time: 0.1 SBU\n\r\tSpace: 36M\n\r\tVersion: 2.2.0"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
