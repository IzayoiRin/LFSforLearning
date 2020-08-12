# !bin/bash

DYNAMIC_LIB_MK_FILE="Makefile-libbz2_so"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="Bzip2RuningtimeLogs.log"
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
	echo -e "Bzip2\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 6.4M\n\r\tVersion: 1.0.8"
	echo ">>>>> Begin to COMPILE >>>>>"
	icompile
}


main
