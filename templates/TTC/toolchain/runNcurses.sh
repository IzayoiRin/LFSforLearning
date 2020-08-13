# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="{{name}}RuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icompile(){
	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find $conf"
		return 1
	fi
	
	echo "Configuring ... ..."
	# ensure gawk first found during conf
	sed -i s/mawk// $conf
	# ada: without to not build support for Ada compiler on host
	# overwrite: install headers into /tools/include insteadi of /tools/include/nurses
	# widec: enable to build wide-character lib instead of normal causing wclib usable in multibyte or 8-bit locales
	$conf \
	--prefix=/tools \
	--with-shared \
	--without-debug \
	--without-ada \
	--enable-widec \
	--enable-overwrite \
	1> /dev/null 2>$LOGS

	echo "Making ... ..."
    # compile package 
    make 1> /dev/null 2>> $LOGS
    echo "Make-installing ... ..."
    # install compiled package 
    make install 1> /dev/null 2>> $LOGS
    echo "Mapping symlink ... ..."
	ln -sv libncursesw.so /tools/lib/libncurses.so

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
	echo -e "{{name}}\n\r\tApproximate Build Time: {{sbu}}} SBU\n\r\tSpace: {{space}}\n\r\tVersion: {{ver}}"
	echo ">>>>> Begin to COMPILE >>>>>"
	icompile
}


main
