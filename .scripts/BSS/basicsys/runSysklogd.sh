#! bin/bash

CONFIGURE_FILE="configure"
ESS_FILES="${0%/*}/ess/"

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="SysklogdInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
	echo "Fix problems in klogd."
	sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
	sed -i 's/union wait/int/' syslogd.c

    echo "Making ... ..."
    # compile package 
    make 1> /dev/null 2> $LOGS

    echo "Make-installing ... ..."
    # install compiled package 
    make BINDIR=/sbin install 1> /dev/null 2>> $LOGS

    echo "Sysklogd Configuring ... ..."
    cp -v ${ESS_FILES}ld.so.conf /etc/vimrc

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Sysklogd\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 0.6M\n\r\tVersion: 1.5.1"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall
}


main
