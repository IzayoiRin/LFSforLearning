# !/bin/bash

TAR_ROOT="../"
SYSFORMT_X86_64="x86_64"
BUILD_TEMP_ROOT="build/"
CONFIGURE_FILE="configure"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="GccRuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


# Unpack each package  and rename
extract_gcc_requires(){
	tarPack=`ls $TAR_ROOT | grep mp`
	for i in $tarPack
	do
		rename=`echo "$i" | cut -d"-" -f1`
		dir=`echo "$i" | cut -d"." -f1-3`
		tar -xf $TAR_ROOT$i 
		if [ -d $rename ];then
			rm -rf $rename
		fi
		mv -v $dir $rename
done
}

# change the location of GCC's default dynamic linker
# remove /usr/include from search path
reconf_gcc_dynamic_linker(){
	for f in gcc/config/{linux,i386/linux{,64}}.h
	# gcc/config/[linux.h, i386/linux.h, i368/linux64.h] 
	do
		# copy the files to new file named endwith '.orig'
		# `cp -uv file file.orig`
		# -u prevents unexceptd changes to ori file while run twice
		cp -uv $f{,.orig}
		# prepends /tools to /lib(64|32)?/ld
		# replaces hard-coded instances of /usr
		sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' -e 's@/usr@/tools@g' $f.orig > $f
		# define statements to atler default startfile prefix
		echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $f
		# update the timestamp on the copied files
		touch $f.orig
	done    
}

# set default dir for host 64bit lib
set_64_lib_default_directory(){
	case $(uname -m) in
		$SYSFORMT_X86_64 )
		sed -e '/m64=/s/lib64/lib/' \
			-i.orig gcc/config/i386/t-linux64
	;;
	esac
}


icheck(){
	echo 'int main(){}' > dummy.c
	cc dummy.c
	readelf -l a.out | grep ': /tools'
	rm -v dummy.* a.out
}


confP1(){
	# --vesion: compatible with the host's version of glibc
	# --newlib: inhibit_libc prevents compiling of code required libc, since C lib not yet available
	# --headers: cross compiler Gcc need std headers with target sys
	# --local-prefix: default search path usr/local, setting to /tools keep host location out
	# --native-sys-header: default search /usr/include, setting to $LFS/tools/include 
	# shared: link internal libraries statically, disable to avoid host system
	# decimal, threads, libtomic, libgomp, libquadmath, libssp, libvtv, cpp std lib: disabled to build cross compiler and cross-compile temp libc
	# multlib: disabled cause x86-64 not support
	# languages: ensures only c&cpp compilers built
	$1 \
	--target=$LFS_TGT \
	--prefix=/tools \
	--with-glibc-version=2.11 \
	--with-sysroot=$LFS \
	--with-newlib \
	--without-headers \
	--with-local-prefix=/tools \
	--with-native-system-header-dir=/tools/include \
	--disable-nls \
	--disable-shared \
	--disable-multilib \
	--disable-decimal-float \
	--disable-threads \
	--disable-libatomic \
	--disable-libgomp \
	--disable-libquadmath \
	--disable-libssp \
	--disable-libvtv \
	--disable-libstdcxx \
	--enable-languages=c,c++ \
	1>/dev/null 2> $LOGS
}


confP2(){
	echo "! Fix a problem introduced by Glibc-2.31"
	sed -e '1161 s|^|//|' -i ../libsanitizer/sanitizer_common/sanitizer_platform_limits_posix.cc
	# languages: C and C++ compilers are built.
	# pch: disable to not build the pre-compiled header (PCH) for libstdc++.
	# bootstrap: compile several times to ensure it can reporduce itself, disabled causing LFS compiler without need it each time.
	CC=$LFS_TGT-gcc \
	CXX=$LFS_TGT-g++ \
	AR=$LFS_TGT-ar \
	RANLIB=$LFS_TGT-ranlib \
	$1 \
	--prefix=/tools \
	--with-local-prefix=/tools \
	--with-native-system-header-dir=/tools/include \
	--enable-languages=c,c++ \
	--disable-libstdcxx-pch \
	--disable-multilib \
	--disable-bootstrap \
	--disable-libgomp \
	1>/dev/null 2>> $LOGS
}

icompile(){
	if [ "${1}" == "p2" ];then
		# first build of GCC installed internal system headers, but limits.h did not exist in /tools/include/, which not include the extended features of the system header to build full gcc.
		echo "! Add internal sys header < limits.h >"
		cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
		`dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h
	fi
  	
  	echo "Set gcc dynamic linker ..."
    reconf_gcc_dynamic_linker

    echo "Set default lib directory ..."
    set_64_lib_default_directory
    
	if [ ! -d $BUILD_TEMP_ROOT ]; then
		mkdir -v $BUILD_TEMP_ROOT
	fi
	
	cd $BUILD_TEMP_ROOT
	pwd

	conf="../${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find $conf"
		return 1
	fi
	echo "Configuring ... ..."
	if [ "${1}" == "p1" ];then
		confP1 $conf
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

    if [ "${1}" == "p2" ];then
        echo "Mapping symLink ... ..."
        ln -sv gcc  /tools/bin/cc
        echo ">>>>> Self Functional Check >>>>>"
		icheck
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
	 # set default arugments
    if [ $# == 0 ];then
        opt="-xc p1"
    elif [ $1 == "-x" ];then
        opt="-x p0"
    elif [ $# == 2 ];then
        opt=$*
    else
        exit 1
    fi

    pas=`echo $opt | cut -d" " -f2`
    if [ ${pas} == "p1" ];then
        time="10"
        space="3.1G"
    elif [ ${pas} == "p2" ];then
        time="13"
        space="3.7G"
    elif [ ${pas} == "p0" ];then
        echo 
    else
        echo "Error: Illegal intallation pass option."
        exit 1
    fi

    pha=`echo $opt | cut -d" " -f1`
    pha=${pha#*-}
    stop=`expr ${#pha} - 1`

    echo -e "{{name}} ${pas}: \n\r\tApproximate Build Time: ${time} SBU\n\r\tSpcae: ${space}G\n\r\tVersion: 9.2.0"
    # select ipt to execed
    for i in `seq 0 $stop`
    do
        a=${pha:$i:`expr $i + 1`}
        if [ ${a} == "x" ]; then
            echo "Extrating ..."
            extract_gcc_requires
        elif [ ${a} == "c" ]; then
            echo ">>>>> Begin to COMPILE >>>>>"
            icompile $pas
            if [ $? != 0 ];then
                exit 1
            fi
        fi
    done
}


main $*
