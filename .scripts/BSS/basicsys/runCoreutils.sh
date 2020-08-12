# !bin/bash

CONFIGURE_FILE="configure"
PATCH_FILE="coreutils-8.31-i18n-1.patch"

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="CoreutilsInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icheck(){
    echo "Expect Testing ... ..."
    make NON_ROOT_USERNAME=nobody check-root \
    1> /dev/null 2>> $LOGS
    # run the remainder of the tests as the nobody user
    echo "dummy:x:1000:nobody" >> /etc/group
    # Fix some of the permissions
    echo "change ownership: nobody <<< ."
    chown -R nobody .
    su nobody -s /bin/bash \
    -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check" \
    1> /dev/null 2>> $LOGS
    echo "! Remove the temporary group."
    sed -i '/dummy/d' /etc/group
}


iinstall(){
    pch="../${PATCH_FILE}"
    if [ ! -f $pch ];then
        echo "Can't find ${pch}"
        return 1
    fi

    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    echo "Patch Self ... ..."
    # install the documentation
    patch -Np1 -i $pch 1> /dev/null 2> $LOGS
    echo "! Fix loop in a test."
    sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk

    echo "Configuring ... ..."
    autoreconf -fiv 1> /dev/null 2>> $LOGS
    FORCE_UNSAFE_CONFIGURE=1 $conf \
    --prefix=/usr \
    --enable-no-install-program=kill,uptime \
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

    echo "! Move to locations specified."
    mv /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
    mv /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
    mv /usr/bin/{rmdir,stty,sync,true,uname} /bin
    mv /usr/bin/chroot /usr/sbin
    mv /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
    sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8

    echo "! Map LFS-Bootscripts package dependency."
    mv /usr/bin/{head,nice,sleep,touch} /bin

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Coreutils\n\r\tApproximate Build Time: 2.3 SBU\n\r\tSpace: 202M\n\r\tVersion: 8.31"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
