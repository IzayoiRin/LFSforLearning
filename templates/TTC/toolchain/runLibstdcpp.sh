# !bin/bash

BUILD_TEMP_ROOT="build/"
CONFIGURE_FILE="configure"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="{{name}}RuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icomplie(){
	if [ ! -d $BUILD_TEMP_ROOT ];then
		mkdir -v $BUILD_TEMP_ROOT
	fi
	cd $BUILD_TEMP_ROOT
	pwd
	conf="../${1}/${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find $conf"
		return 1
	fi
	echo "Configuring ... ..."
	# host: set cross compiler built by Binutils$GCC instead of host's /usr/bin
	# lib-treads: GCC without thread support
	# lib-pch: disable to prevents intalling precompiled files
	# gxx-include: set searching path of CPP compiler's stanard include files
	$conf \
	--host=$LFS_TGT \
	--prefix=/tools \
	--disable-multilib \
	--disable-nls \
	--disable-libstdcxx-threads \
	--disable-libstdcxx-pch \
	--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/9.2.0 \
	1> /dev/null 2>> $LOGS

	echo "Making ... ..."
	# compile package 
	make 1> /dev/null 2>> $LOGS
	echo "Make-installing ... ..."
	# install compiled package 
	make install 1> /dev/null 2>> $LOGS

	echo "Cleaning Temps ... ..."
	cd ../
    rm -rf $BUILD_TEMP_ROOT
    pwd
	return 0
}


main(){
 	echo -e "{{name}}\n\r\tApproximate Build Time: {{sbu}}} SBU\n\r\tSpace: {{space}}\n\r\tVersion: {{ver}}"
    package="libstdc++*"
    package_dir=`ls -F | grep $package | cut -d"/" -f1`
    echo "Found ${package_dir}"
    if [[ ! -d ${package_dir} ]];then
        echo "Can't find package Libstdc++"
        return 1
    fi
    echo ">>>>> Begin to COMPILE >>>>>"
    icomplie $package_dir
}


main
