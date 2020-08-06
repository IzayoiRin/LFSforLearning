# !bin/bash

CONFIGURE_FILE="Configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="PerlInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    # referenced in one of Perl's configuration files.
    echo "! Create a basic /etc/hosts file "
    echo "127.0.0.1 localhost $(hostname)" > /etc/hosts

    echo "! Use system lib for zlib & bzip2"
    export BUILD_ZLIB=False
    export BUILD_BZIP2=0

    echo "Configuring ... ..."
    # Dvendorprefix: path install their perl modules.
    # Dpager: less is used instead of more
    # Dman*dir: make man pages for Perl dut to decent Groff.
    # Duseshrplib: shared libperl needed by some perl modules.
    # Dusethreads: support for threads
    sh $conf -des \
    -Dprefix=/usr \
    -Dvendorprefix=/usr \
    -Dman1dir=/usr/share/man/man1 \
    -Dman3dir=/usr/share/man/man3 \
    -Dpager="/usr/bin/less -isR" \
    -Duseshrplib \
    -Dusethreads \
    1> /dev/null 2> $LOGS

    # compile package 
    echo "Making ... ..."
    make 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
        echo "Expect Testing ... ..."
        make test 1> /dev/null 2>> $LOGS
    fi

    # install compiled package 
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS

    echo "Cleaning Temps ... ..."
    unset BUILD_ZLIB BUILD_BZIP2
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Perl\n\r\tApproximate Build Time: 9.2 SBU\n\r\tSpace: 272M\n\r\tVersion: 5.30.1"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
