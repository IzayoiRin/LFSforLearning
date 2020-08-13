SETUP_ENV="/chroot/"
SETUP="${SETUP_ENV}ess/setup_root.sh"
RMTEMP="${SETUP_ENV}ess/rm_temp.sh"
UCONF="${SETUP_ENV}/ess/usr_configure.sh"
INSTALLER1="${SETUP_ENV}installer.sh"
INSTALLER2="${SETUP_ENV}installer2.sh"
UNINSTALLER="${SETUP_ENV}uninstaller.sh"

SUCE_CALL_BACK_FLG=200


init_virtual_kernel_fs(){
    # Create directories onto which the file systems will be mounted
    sudo mkdir -pv $LFS/{dev,proc,sys,run}
    # Create Initial Device Nodes
    echo "! Create Initial Device Nodes."
    sudo mknod -m 600 $LFS/dev/console c 5 1
    sudo mknod -m 666 $LFS/dev/null c 1 3
    # Mount and Populating /dev as bind mount
    echo "! Mounte and Populate /dev"
    sudo mount -v --bind /dev $LFS/dev
    # Mounte and Populate /boot
    if [ -d /boot ];then
        echo "! Mounte and Populate /boot"
        sudo mount -v --bind /boot $LFS/boot
    fi
    # Mount the virtual kernel filesystems
    # gid=5: all devpts-created device nodes are owned by group ID 5
    # mode=0620: user readable and writable, group writable
    echo "! Mount Virtual Kernel File Systems."
    sudo mount -vt devpts devpts $LFS/dev/pts -o gid=5,mode=620
    sudo mount -vt proc proc $LFS/proc
    sudo mount -vt sysfs sysfs $LFS/sys
    sudo mount -vt tmpfs tmpfs $LFS/run
    # some host, /dev/shm is a symbolic link to /run/shm
    if [ -h $LFS/dev/shm ]; then
        mkdir -pv $LFS/$(readlink $LFS/dev/shm)
    fi
}


init_chroot_env(){
    # Enter the Chroot Environment
    # change root dir
    # chroot targetdir exec 
    # env --i: clear all variables
    # HOME, TERM, PS1, and PATH variables are set again
    # TERM: needed for programs like vim and less 
    # temporary tool will no longer be used once final version installed   
    # shell remember the locations of executed binaries
    echo "Current: /tools/bin/bash"
    sudo chroot $LFS /tools/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h ${1}
}


chroot_env(){
    echo "Current: $(readlink $LFS/bin/bash || echo "/bin/bash")"
    sudo chroot $LFS /tools/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    $(readlink $LFS/bin/bash || echo "/bin/bash") --login +h ${1}
}


chroot_env_usr(){
    echo "Current: /bin/bash"
    sudo chroot "$LFS" /usr/bin/env -i \
    HOME=/root TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login ${1}
}


setup_bss(){
    chroot_env ${INSTALLER1}
    if [ "$?" == "${SUCE_CALL_BACK_FLG}" ];then
        chroot_env $INSTALLER2
    fi
    if [ "$?" == "${SUCE_CALL_BACK_FLG}" ];then
        echo "! ensure none of the binaries about to be stripped."
        init_chroot_env $UNINSTALLER
    fi
}


insh(){
    if [ -d ${LFS}/tools/ ];then
        echo ok
        chroot_env
    else
        chroot_env_usr
    fi
}


main(){
    if [ "${1}" == "--init" ];then
        echo "##### Prepare Virtual File System #####"
        init_virtual_kernel_fs
        
        if [ "${2}" == "virtual" ];then
            return 0
        fi

        echo "####### Setup Root Environment #######"
        init_chroot_env ${SETUP}
        return 0
    fi
    echo "####### Change Root Environment #######"
    if [ "${1}" == "--sh" ];then
        insh
    elif [ "${1}" == "--rmtemp" ];then
        chroot_env_usr ${RMTEMP}
    elif [ "${1}" == "--setup" ];then
        setup_bss
    elif [ "${1}" == "--uconf" ];then
        chroot_env_usr ${UCONF}
    else
        echo "Wrong params ${1} from command."
    fi
    return 0
}


main $*
