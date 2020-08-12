# !bin/bash

CONFIGURE_FILE="configure"
SYSFORMT_X86_32="x86_32"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="GMPInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    ABI=64
    if [ "$(uname -m)" == "${SYSFORMT_X86_32}" ];then
        echo "! Ada for $(uname -m) sys."
        ABI=32
    fi

    if [ "${1}" == "--pro-enhance" ];then
        echo "! Enhance processors capablity."
        cp -v configfsf.guess config.guess
        cp -v configfsf.sub config.sub
    fi

    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    echo "Configuring ... ..."
    # cxx: enable to support cpp
    # docdir:  correct place for the documentation
    ABI=${ABI} $conf \
    --prefix=/usr \
    --enable-cxx \
    --disable-static \
    --docdir=/usr/share/doc/gmp-6.2.0 \
    1> /dev/null 2> $LOGS

    # Compile the package and generate the HTML documentation
    echo "Making ... ..."
    make 1> /dev/null 2>> $LOGS
    make html 1> /dev/null 2>> $LOGS

    # critical necessary test, do not skip
    echo "Expect Testing ... ..."
    make check 1> temp-gmp-check-log 2>>$LOGS
    # row: # PASS:  3
    pass=$(awk '/# PASS:/{pass+=$3} ; END{print pass}' temp-gmp-check-log)
    # row: # TOTAL:  3
    total=$(awk '/# TOTAL:/{total+=$3} ; END{print total}' temp-gmp-check-log)
    if [ "${pass}" != "${total}" ];then
        echo "!!! `expr ${total} - ${pass} ` Tests Failed !!!"
        return 1
    fi
    echo "! Whole ${pass} tests passed."
    rm -v temp-gmp-check-log

    # Install the package and its documentation
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS
    make install-html 1> /dev/null 2>> $LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "GMP\n\r\tApproximate Build Time: 1.1 SBU\n\r\tSpace: 51M\n\r\tVersion: 6.2.0"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
