# !bin/bash

CONFIGURE_FILE="configure"
ESS_FILES="${0%/*}/ess/"

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="ShadowInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


clear_temp(){
    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


conf_shadow(){
    echo "! Enable shadowed passwords."
    pwconv
    echo "! Enable shadowed group passwords."
    grpconv
    echo "! Set password for user root"
    chpasswd < ${ESS_FILES}pwd.ini
}


iinstall(){
    # Disable groups and its man pages as Coreutils provides better version.
    echo "! Disable < groups > & its man-pages." 
    sed -i 's/groups$(EXEEXT) //' src/Makefile.in
    find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
    find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
    find man -name Makefile.in -exec sed -i 's/passwd\.5 / /' {} \;
    
    # Instead of default crypt, use SHA-512, change the obsolete /var/spool/mail for user mailboxes by default to the /var/mail. 
    echo "! Change to SHA512 pwd encryption & mailboxes loaction."
    sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
    -e 's@/var/spool/mail@/var/mail@' etc/login.defs

    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi
    echo "Configuring ... ..."

    # build Shadow with Cracklib support
    # group-name: with to make max user name 32.
    if [ "${1}" == "--strong" ];then
        echo "! Build strong pwd encryption with Cracklib."
        sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' etc/login.defs   
        $conf \
        --sysconfdir=/etc \
        --with-group-name-max-length=32 \
        --with-libcrack \
        1> /dev/null 2> $LOGS
    else
        $conf \
        --sysconfdir=/etc \
        --with-group-name-max-length=32 \
        1> /dev/null 2> $LOGS
    fi

    # compile package
    echo "Making ... ..." 
    make 1> /dev/null 2>> $LOGS

    # install compiled package 
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS
}


main(){
    echo -e "Shadow\n\r\tApproximate Build Time: 0.2 SBU\n\r\tSpace: 46M\n\r\tVersion: 4.8.1"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
    echo ">>>>> Configuring Shadow >>>>>"
    conf_shadow
    clear_temp
}


main $*
