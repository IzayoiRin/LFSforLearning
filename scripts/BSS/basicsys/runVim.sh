# !bin/bash

CONFIGURE_FILE="configure"
ESS_FILES="${0%/*}/ess/"

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="VimInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icheck(){
    echo "Expect Testing ... ..."
    chown -Rv nobody .
    su nobody -s /bin/bash \
    -c "LANG=en_US.UTF-8 make -j1 test" &> vim-test.log
}


iinstall(){
    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi
    echo "! Change the default location of the vimrc"
    echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

    echo "Configuring ... ..."
    $conf \
    --prefix=/usr \
    1> /dev/null 2>> $LOGS

    # compile package 
    echo "Making ... ..."
    make 1> /dev/null 2>> $LOGS


    if [ "${1}" == "--test" ];then
        icheck
    fi

    echo "Make-installing ... ..."
    # install compiled package 
    make install 1> /dev/null 2>> $LOGS

    ln -sv vim /usr/bin/vi
    for L in /usr/share/man/{,*/}man1/vim.1; do
        ln -sv vim.1 $(dirname $L)/vi.1
    done
    
    ln -sv ../vim/vim82/doc /usr/share/doc/vim-8.2.0190

    cp -v ${ESS_FILES}ld.so.conf /etc/vimrc

    vim -c ':options'

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Vim\n\r\tApproximate Build Time: 1.7 SBU\n\r\tSpace: 202M\n\r\tVersion: 8.2.0190"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
