# !bin/bash

PATCH_FILE="glibc-2.31-fhs-1.patch"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="Bzip2InstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
	pch="../${PATCH_FILE}"
	if [ ! -f $pch ];then
		echo "Can't find ${pch}"
		return 1
	fi
	echo "Patch Self ... ..."
	# install the documentation
	patch -Np1 -i $pch 1> /dev/null 2> $LOGS

	echo "Configuring ... ..."
	# installation of symlink are relative
	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
	# install into the correct location
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
	# prepare for compilation\
	# build with Makefile-libbz2_so to create dl libbz2.so and link with
	make -f Makefile-libbz2_so
	make clean

	echo "Making ... ..."
	# compile package 
	make 1> /dev/null 2>> $LOGS

	echo "Make-installing ... ..."
	# install compiled package 
	make PREFIX=/usr install 1> /dev/null 2>> $LOGS

	# Install the shared bzip2 binary into the /bin directory
	echo "! Build shared binary"
	cp -v bzip2-shared /bin/bzip2
	cp -av libbz2.so* /lib
	ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
	rm -v /usr/bin/{bunzip2,bzcat,bzip2}
	ln -sv bzip2 /bin/bunzip2
	ln -sv bzip2 /bin/bzcat

	echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
	echo -e "Bzip2\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 5.1M\n\r\tVersion: 1.0.8"
	echo ">>>>> Begin to COMPILE >>>>>"
	iinstall
}


main
