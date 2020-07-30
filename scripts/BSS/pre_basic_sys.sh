SETUP_ENV="/chroot"
SETUP="${SETUP_ENV}/setup_root.sh"


init_virtual_kernel_fs(){
    # Create directories onto which the file systems will be mounted
    mkdir -pv $LFS/{dev,proc,sys,run}
    # Create Initial Device Nodes
    mknod -m 600 $LFS/dev/console c 5 1
    mknod -m 666 $LFS/dev/null c 1 3
    # Mount and Populating /dev as bind mount
    sudo mount -v --bind /dev $LFS/dev
    # Mount the virtual kernel filesystems
    # gid=5: all devpts-created device nodes are owned by group ID 5
    # mode=0620: user readable and writable, group writable
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
    sudo chroot $LFS /tools/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h ${SETUP}
    # exec /tools/bin/bash --login +h
}


main(){
	echo "##### Prepare Virtual File System #####"
	init_virtual_kernel_fs
	echo "####### Change Root Environment #######"
	init_chroot_env
}


main
