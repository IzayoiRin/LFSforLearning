#! bin/bash

ESS_FILES="${0%/*}/ess/"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="LinuxAPIInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    echo "! Ensuring no stale files" 
    make mrproper

    echo "Configuring ... ..."
    make defconfig 1> /dev/null 2> $LOGS
    make menuconfig

    echo "Making ... ..."
    make 1> /dev/null 2>> $LOGS

    echo "Make-installing ... ..."
    make modules_install 1> /dev/null 2>> $LOGS

    echo "Mapping to /boot ... ..."
    cp -iv arch/x86/boot/bzImage /boot/vmlinuz-5.5.3-lfs-9.1
    cp -iv System.map /boot/System.map-5.5.3
    cp -iv .config /boot/config-5.5.3
    install -d /usr/share/doc/linux-5.5.3
	cp -r Documentation/* /usr/share/doc/linux-5.5.3

    chown -R 0:0 .
    install -v -m755 -d /etc/modprobe.d
    copy -v ${ESS_FILES}usb.conf /etc/modprobe.d

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "LinuxAPI\n\r\tApproximate Build Time: 6 SBU\n\r\tSpace: 1.1G\n\r\tVersion: 5.5.3"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall
}


main
