# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="OpenSSLInstallLogs.log"
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
    --openssldir=/etc/ssl \
    --libdir=lib \
    shared \
    zlib-dynamic \
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
    sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
    make MANSUFFIX=ssl install \
    1> /dev/null 2>> $LOGS

    echo "Install documentation ... ..."
    mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1d
    cp -fr doc/* /usr/share/doc/openssl-1.1.1d

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "OpenSSL\n\r\tApproximate Build Time: 2.1 SBU\n\r\tSpace: 146M\n\r\tVersion: 1.1.1d"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
