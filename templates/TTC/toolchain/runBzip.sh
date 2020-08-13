# !bin/bash

DYNAMIC_LIB_MK_FILE="Makefile-libbz2_so"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="{{name}}RuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icompile(){
	# does not contain a configure script but with 2 makefile:
	# shared lib & static lib
	conf="./${DYNAMIC_LIB_MK_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find $conf"
		return 1
	fi
	# creates a dynamic libbz2.so library and links the Bzip2 utilities
	echo "Making dynamic lib ... ..."
	make -f $conf 1> /dev/null 2> $LOGS
	make clean
	echo "Making static lib ... ..."
	make 1> /dev/null 2>> $LOGS
	echo "Make-installing ... ..."
	make PREFIX=/tools install 1> /dev/null 2>> $LOGS
	cp -v bzip2-shared /tools/bin/bzip2
	cp -av libbz2.so* /tools/lib
	echo "Mapping symlink ... ..."
	ln -sv libbz2.so.1.0 /tools/lib/libbz2.so

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
