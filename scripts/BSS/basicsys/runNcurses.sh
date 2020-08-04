# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="NcursesInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


clear_temp(){
    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


iinstall(){
	echo "! Disable static library"
	sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in

	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find ${conf}"
		return 1
	fi

	echo "Configuring ... ..."
	# widec: enable to built wide-character lib instead of normal
	# pc-files: enable to generate .pc files for pkg
	# normal: without static lib 
	$conf \
	--prefix=/usr \
	--mandir=/usr/share/man \
	--with-shared \
	--without-debug \
	--without-normal \
	--enable-pc-files \
	--enable-widec \
	1> /dev/null 2> $LOGS

	# compile package
	echo "Making ... ..." 
	make 1> /dev/null 2>> $LOGS
 	
 	# install compiled package 
    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS

    # shared lib moved to /lib and recreate symlink
    echo "move: /usr/lib/libncursesw.so.6* ---> /lib"
    mv /usr/lib/libncursesw.so.6* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so

    # Trick applications into linking with wide-character libraries
    echo "!	Trick apps into linking with wc-ncurses-lib."
    for lib in ncurses form panel menu ; do
		rm -vf /usr/lib/lib${lib}.so
		echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
		ln -sfv ${lib}w.pc /usr/lib/pkgconfig/${lib}.pc
	done

	# make sure that old applications that look for -lcurses at build time are still buildable
	echo "! Ensure apps looking for <-lcurses> buildable."
	rm -vf /usr/lib/libcursesw.so
	echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
	ln -sfv libncurses.so /usr/lib/libcurses.so

	echo "Install Ncurses documentation ... ..."
	mkdir -v /usr/share/doc/ncurses-6.2
	cp -R doc/* /usr/share/doc/ncurses-6.2

	clear_temp
}


main(){
	echo -e "Ncurses\n\r\tApproximate Build Time: 0.4 SBU\n\r\tSpace: 43M\n\r\tVersion: 6.2"
	echo ">>>>> Begin to COMPILE >>>>>"
	iinstall 
}


main 
