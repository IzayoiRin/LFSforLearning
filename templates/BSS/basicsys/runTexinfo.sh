# !/bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="TexinfoInstallLogs.log"
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

    echo "TeX installing ... ..."
    make TEXMF=/usr/share/texmf install-tex \
    1> /dev/null 2>> $LOGS

    pushd /usr/share/info
    rm -v dir
    for f in *
        do install-info $f dir >/dev/null 2>&1
    done
    popd

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Texinfo\n\r\tApproximate Build Time: 0.7 SBU\n\r\tSpace: 116M\n\r\tVersion: 6.7"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
