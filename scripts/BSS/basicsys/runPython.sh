# !bin/bash

CONFIGURE_FILE="configure"
DOCS_PACK="python-3.8.1-docs-html.tar.bz2"

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="PythonInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    docs="../${DOCS_PACK}"
    if [ ! -f $docs ];then
        echo "Can't find ${docs}"
        return 1
    fi

    echo "Configuring ... ..."
    # libgdbm: enable with libgdbm compatibility library to provide older DBM 
    $conf \
    --prefix=/usr \
    --enable-shared \
    --with-system-expat \
    --with-system-ffi \
    --with-ensurepip=yes \
    1> /dev/null 2> $LOGS

    # compile package 
    echo "Making ... ..."
    make 1> /dev/null 2>> $LOGS

    # install compiled package 
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS
    chmod -v 755 /usr/lib/libpython3.8.so
    chmod -v 755 /usr/lib/libpython3.so
    ln -sfv pip3.8 /usr/bin/pip3

    echo "Install documentation ... ..."
    install -dm755 /usr/share/doc/python-3.8.1/html \
    1> /dev/null 2>> $LOGS
    
    tar --strip-components=1 \
    --no-same-owner \
    --no-same-permissions \
    -C /usr/share/doc/python-3.8.1/html \
    -xf $docs

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Python\n\r\tApproximate Build Time: 1.2 SBU\n\r\tSpace: 426M\n\r\tVersion: 3.8.1"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall
}


main
