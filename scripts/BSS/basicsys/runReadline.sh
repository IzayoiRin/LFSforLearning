# !bin/bash

CONFIGURE_FILE="configure"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="ReadlineInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
	# Reinstall cause old libraries to be moved to <libraryname>.old triggering linking bug in ldconfig
	echo "! Fix inherit problems"
	sed -i '/MV.*old/d' Makefile.in
	sed -i '/{OLDSUFF}/c:' support/shlib-instal

	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find ${conf}"
		return 1
	fi

	echo "Configuring ... ..."
	$conf \
	--prefix=/usr \
	--disable-static \
	--docdir=/usr/share/doc/readline-8.0 \
	1> /dev/null 2> $LOGS

	echo "Making ... ..."
	# SHLIB_LIBS: forces Readline to link against the libncursesw library
	make SHLIB_LIBS="-L/tools/lib -lncursesw" \
	1> /dev/null 2>> $LOGS

    echo "Make-installing ... ..."
    # install compiled package 
    make SHLIB_LIBS="-L/tools/lib -lncursesw" install \
    1> /dev/null 2>> $LOGS
    # dl to a more appropriate location & fix up permissions and symbolic links
    mv -v /usr/lib/lib{readline,history}.so.* /lib
	chmod -v u+w /lib/lib{readline,history}.so.*
	ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
	ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so
	#  install the documentation
	install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.0

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}



main(){
	echo -e "Readline\n\r\tApproximate Build Time: 0.1 SBU\n\r\tSpace: 15M\n\r\tVersion: 8.0"
	echo ">>>>> Begin to COMPILE >>>>>"
	iinstall 
}


main 
