# !/bin/bash

CONFIGURE_FILE="configure"
PATCH_FILE="bash-5.0-upstream_fixes-1.patch"

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="BashInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


clear_temp(){
    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


iinstall(){
	pch="../${PATCH_FILE}"
	if [ ! -f $pch ];then
		echo "Can't find ${pch}"
		return 1
	fi
	echo "Patch Self ... ..."
	# install the documentation
	patch -Np1 -i $pch 1> /dev/null 2> $LOGS

	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find ${conf}"
		return 1
	fi
	
	# readline: with readline lib instead of its own version
	echo "Configuring ... ..."
	./configure \
	--prefix=/usr \
	--docdir=/usr/share/doc/bash-5.0 \
	--without-bash-malloc \
	--with-installed-readline \
	1> /dev/null 2>> $LOGS
	
	# compile package 
	echo "Making ... ..."
	make 1> /dev/null 2>> $LOGS

    if [ "${1}" == "--test" ];then
	    echo "Expect Testing ... ..."
	    chown -Rv nobody 
	    su nobody -s /bin/bash -c "PATH=$PATH HOME=/home make tests" \
	    1> /dev/null 2>> $LOGS
    fi
	
	# install compiled package 
	echo "Make-installing ... ..."
	make install 1> /dev/null 2>> $LOGS
	mv -vf /usr/bin/bash /bin
	
	clear_temp
}


main(){
	echo -e "Bzip2\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 5.1M\n\r\tVersion: 1.0.8"
	echo ">>>>> Begin to COMPILE >>>>>"
	iinstall $*
}


main $*
