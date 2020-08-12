# !bin/bash

BUILD_TEMP_ROOT="build/"
CONFIGURE_FILE="configure"

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="BinutilsInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


clear_temp(){
    echo "Cleaning Temps ... ..."
    cd ../;dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


iinstall(){
    echo "! Verify PTYs working properly."
    msg=`expect -c "spawn ls"`
    if [ ${msg%% *} == "spawn" ];then
        echo "Verify Pass"
    else
        echo $msg
        return 1
    fi
    echo "! Fix one test problems."
    # remove one test that prevents the tests from running to completion
    sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in

    if [ ! -d $BUILD_TEMP_ROOT ];then
        mkdir -v $BUILD_TEMP_ROOT
    fi
    cd $BUILD_TEMP_ROOT
    pwd

    conf="../${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    echo "Configuring ... ..."
    # gold: enable to build gold linker as ld.gold
    # ld: ori bfd linker as ld & ld.bfd
    # plugins: enable to support for linker
    # 64-bit-bfd: enable to support 64bit
    # system-zlib: with zlib lib instead of include
    $conf \
    --prefix=/usr \
    --enable-gold \
    --enable-ld=default \
    --enable-plugins \
    --enable-shared \
    --disable-werror \
    --enable-64-bit-bfd \
    --with-system-zlib \
    1> /dev/null 2> $LOGS

    echo "Making ... ..."
    # tooldir: normall set to $(exec_prefix)/$(target_alias), which used to cross compile, but for custom sys /usr not required
    make tooldir=/usr 1> /dev/null 2>> $LOGS

    # critical necessary test, do not skip
    echo "Expect Testing ... ..."
    make -k check 1> /dev/null 2>> $LOGS

    echo "Make-installing ... ..."
    # install compiled package 
    make tooldir=/usr install 1> /dev/null 2>> $LOGS

    clear_temp
}


main(){
    echo -e "Binutils\n\r\tApproximate Build Time: 6.7 SBU\n\r\tSpace: 5.1G\n\r\tVersion: 2.34"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall
}


main
