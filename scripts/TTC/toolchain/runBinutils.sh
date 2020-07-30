# !bin/bash

SYSFORMT_X86_64="x86_64"
BUILD_TEMP_ROOT="build/"
CONFIGURE_FILE="configure"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="BinutilsRuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"

# create a symlink of the toolchain for host 64bit
set_64_toolchain_symlink(){
    case $(uname -m) in
        x86_64)
        mkdir -v /tools/lib && ln -sv lib /tools/lib64
    ;;
    esac
}


confP1(){
    # --prefix: install dir
    # --with-sysroot: cross compilation >> target sys libraries
    # --with-lib-path: linker library path
    # --target: machine description
    # --disable-nls: disable internationalization 
    # --disable-werror: disable warnings from the host's compiler
    $1 \
    --prefix=/tools \
    --with-sysroot=$LFS \
    --with-lib-path=/tools/lib \
    --target=$LFS_TGT \
    --disable-nls \
    --disable-werror \
    1> /dev/null 2> $LOGS
}


confP2(){
    # CC, AR, RANLIB: crosscompiler and associated tools instead of the ones on the host system cause native Binutils
    # --with-lib-path: linker library path
    # --disable-nls: disable internationalization 
    # --disable-werror: disable warnings from the host's compiler
    # --with-sysroot: default non-existent sysroot directory /tools/$LFS_TGT/sys-root. search into <sysroot>/etc/ld.so.conf >> linker search path.
    CC=$LFS_TGT-gcc \
    AR=$LFS_TGT-ar \
    RANLIB=$LFS_TGT-ranlib \
    $1 \
    --prefix=/tools \
    --disable-nls \
    --disable-werror \
    --with-lib-path=/tools/lib \
    --with-sysroot \
    1> /dev/null 2>> $LOGS
}


for_re_adjusting(){
    # remove all compiled files in ld
    make -C ld clean 1> /dev/null 2>> $LOGS
    # rebuilds ld. LIB_PATH override temp tools 's dafault >> linker's default lib search path
    make -C ld LIB_PATH=/usr/lib:/lib 1> /dev/null 2>> $LOGS
    cp -v ld/ld-new /tools/bin
}


icompile(){
    if [ ! -d $BUILD_TEMP_ROOT ];then
        mkdir -v $BUILD_TEMP_ROOT
    fi
    cd $BUILD_TEMP_ROOT
    pwd

    conf="../${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find $conf"
        return 1
    fi

    echo "Configuring ${1} ... ..."
    if [ "${1}" == "p1" ];then
        confP1 $conf

        echo "Set toolchain symlink ..."
        set_64_toolchain_symlink
    
    elif [ "${1}" == "p2" ];then
        confP2 $conf
    else
        return 1
    fi

    echo "Making ... ..."
    # compile package 
    make 1> /dev/null 2>> $LOGS
    
    echo "Make-installing ... ..."
    # install compiled package 
    make install 1> /dev/null 2>> $LOGS

    if [ "$1" == "p2" ];then
        echo "Preparing for Re-adjusting ... ..."
        for_re_adjusting
    fi

    echo "Cleaning Temps ... ..."
    if [ "${1}" == "p1" ];then
        cd ../
        rm -rf $BUILD_TEMP_ROOT
    elif [ "${1}" == "p2" ];then
        cd ../;dir=`pwd`;cd ../
        echo "remove ${dir}"
        rm -rf $dir
    fi
    pwd
    return 0
}


main(){
    if [ "${1}" == "p1" ];then
        time="1"
        space="625"
    elif [ "${1}" == "p2" ];then
        time="1.1"
        space="651"
    else
        echo "Error: Illegal intallation pass option."
        exit 1
    fi
    echo -e "Binutils ${1}: \n\r\tApproximate Build Time: ${time} SBU\n\r\tSpace: ${space}M\n\r\tVersion: 2.34"
    echo ">>>>> Begin to COMPILE >>>>>"
    icompile $1
    if [ $? != 0 ];then
        exit 1
    fi
}


main $*
