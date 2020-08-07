# !bin/bash

BUILD_TEMP_ROOT="build/"
CONFIGURE_FILE="configure"

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="E2fsprogsInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


clear_temp(){
    echo "Cleaning Temps ... ..."
    cd ../;dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


iinstall(){
    if [ ! -d $BUILD_TEMP_ROOT ];then
        mkdir -v $BUILD_TEMP_ROOT
    fi
    cd $BUILD_TEMP_ROOT
    pwd

    conf="../${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    echo "Configuring ... ..."
    $conf \
    --prefix=/usr \
    --bindir=/bin \
    --with-root-prefix="" \
    --enable-elf-shlibs \
    --disable-libblkid \
    --disable-libuuid \
    --disable-uuidd \
    --disable-fsck \
    1> /dev/null 2> $LOGS

    echo "Making ... ..."
    # tooldir: normall set to $(exec_prefix)/$(target_alias), which used to cross compile, but for custom sys /usr not required
    make 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
        echo "Expect Testing ... ..."
        make check 1> /dev/null 2>> $LOGS
    fi

    echo "Make-installing ... ..."
    # install compiled package 
    make install 1> /dev/null 2>> $LOGS

    chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

    echo "gunzip: /usr/share/info/libext2fs.info.gz"
    gunzip /usr/share/info/libext2fs.info.gz
    install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info \
    1> /dev/null 2>> $LOGS

    echo "Install additional documentation ... ..."
    makeinfo -o doc/com_err.info ../lib/et/com_err.texinfo \
    1> /dev/null 2>> $LOGS

    install -m644 doc/com_err.info /usr/share/info \
    1> /dev/null 2>> $LOGS
    
    install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info \
    1> /dev/null 2>> $LOGS

    clear_temp
}


main(){
    echo -e "E2fsprogs\n\r\tApproximate Build Time: 1.6 SBU\n\r\tSpace: 108M\n\r\tVersion: 1.45.5"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $1
}


main $*
