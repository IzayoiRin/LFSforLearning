# !/bin/bash

BUILD_TEMP_ROOT="build/"
CONFIGURE_FILE="configure"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="GlibcRuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icheck(){
	echo 'int main(){}' > dummy.c
	$LFS_TGT-gcc dummy.c
	readelf -l a.out | grep ': /tools'
	rm -v dummy.* a.out
}


icompile(){
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
	# --host, build: conf to cross-compile with cross-linker & cross-compiler in /tools
	# --kernel: compile library with >=3.2 kernel
	# header: compiled from headers installed in /tools/include through GCC
	$conf \
	--prefix=/tools \
	--host=$LFS_TGT \
	--build=$(../scripts/config.guess) \
	--enable-kernel=3.2 \
	--with-headers=/tools/include \
	1> /dev/null 2>>$LOGS
	
	echo "Making ... ..."
	# compile package 
	make 1> /dev/null 2> $LOGS
	echo "Make-installing ... ..."
	# install compiled package 
	make install 1> /dev/null 2>> $LOGS

	echo "Cleaning Temps ... ..."
	cd ../;dir=`pwd`;cd ../
	echo "remove ${dir}"
	rm -rf $dir
	pwd
	return 0
}


main(){
	echo -e "Glibc\n\r\tApproximate Build Time: 4.5 SBU\n\r\tSpace: 896M\n\r\tVersion: 2.31"
	echo ">>>>> Begin to COMPILE >>>>>"
	icompile
	if [ $? != 0 ];then
		exit 1
	fi
	echo ">>>>> Self Functional Check >>>>>"
	icheck
}


main
