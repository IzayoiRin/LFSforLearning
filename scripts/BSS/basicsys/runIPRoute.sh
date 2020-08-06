# !bin/bash

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="IPRoute2InstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    echo "Configuring ... ..."
    sed -i /ARPD/d Makefile
    rm -fv man/man8/arpd.8
    sed -i 's/.m_ipt.o//' tc/Makefile

    # compile package 
    echo "Making ... ..."
    make 1> /dev/null 2> $LOGS

    # install compiled package 
    echo "Make-installing ... ..."
    make DOCDIR=/usr/share/doc/iproute2-5.5.0 install \
    1> /dev/null 2>> $LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "IPRoute2\n\r\tApproximate Build Time: 0.2 SBU\n\r\tSpace: 14M\n\r\tVersion: 5.5.0"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall 
}


main 
