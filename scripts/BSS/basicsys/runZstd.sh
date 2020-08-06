# !bin/bash

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="ZstdInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    # compile package 
    echo "Making ... ..."
    make 1> /dev/null 2> $LOGS

    # install compiled package 
    echo "Make-installing ... ..."
    make  prefix=/usr install 1> /dev/null 2>> $LOGS

    rm -v /usr/lib/libzstd.a
    mv -v /usr/lib/libzstd.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libzstd.so) /usr/lib/libzstd.so

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Zstd\n\r\tApproximate Build Time: 0.7 SBU\n\r\tSpace: 16M\n\r\tVersion: 1.4.4"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall 
}


main 
