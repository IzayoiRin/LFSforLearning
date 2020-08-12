# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="Procps-ngInstallLogs.log"
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
    --exec-prefix= \
    --libdir=/usr/lib \
    --docdir=/usr/share/doc/procps-ng-3.3.15 \
    --disable-static \
    --disable-kill \
    1> /dev/null 2> $LOGS

    # compile package 
    echo "Making ... ..."
    make 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
        echo "! Remove a test"
        sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
        sed -i '/set tty/d' testsuite/pkill.test/pkill.exp
        rm testsuite/pgrep.test/pgrep.exp

        echo "Expect Testing ... ..."
        make check 1> /dev/null 2>> $LOGS
    fi

    # install compiled package 
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS

    echo "move: /usr/lib/libprocps.so.* ---> /lib"
    mv /usr/lib/libprocps.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Procps-ng\n\r\tApproximate Build Time: 0.1 SBU\n\r\tSpace: 17M\n\r\tVersion: 3.3.15"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $1
}


main $*
