# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="TclRuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icompile(){
    cd $1
    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find $conf"
        return 1
    fi
    echo "Configuring ... ..."
    $conf --prefix=/tools \
    1>/dev/null 2>$LOGS

    echo "Making ... ..."
    # compile package 
    make 1> /dev/null 2>> $LOGS
    if [ "${2}" == "--test" ];then
        echo "TCL Testing ... ..."
        TZ=UTC make test 1> /dev/null 2>> $LOGS
    fi
    echo "Make-installing ... ..."
    # install compiled package 
    make install 1> /dev/null 2>> $LOGS
    chmod -v u+w /tools/lib/libtcl8.6.so
    
    echo "Header Installing ... ..."
    make install-private-headers
    echo "Mapping Symlink ... ..."
    ln -sv tclsh8.6 /tools/bin/tclsh

    echo "Cleaning Temps ... ..."
    cd ../;dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Tcl\n\r\tApproximate Build Time: 0.9 SBU\n\r\tSpace: 72M\n\r\tVersion: 8.6.10"
    package="unix"
    package_dir=`ls -F | grep $package | cut -d"/" -f1`
    echo "Found ${package_dir}"
    if [[ ! -d ${package_dir} ]];then
        echo "Can't find package Libstdc++"
        return 1
    fi
    echo ">>>>> Begin to COMPILE >>>>>"
    icompile $package $1
}


main $*
