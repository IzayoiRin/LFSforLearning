# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="GRUBInstallLogs.log"
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
    --sbindir=/sbin \
    --sysconfdir=/etc \
    --disable-efiemu \
    --disable-werror \
    1> /dev/null 2> $LOGS

    # compile package 
    echo "Making ... ..."
    make 1> /dev/null 2>> $LOGS

    # install compiled package 
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS

    mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "GRUB\n\r\tApproximate Build Time: 0.8 SBU\n\r\tSpace: 161M\n\r\tVersion: 2.04"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall 
}


main 
