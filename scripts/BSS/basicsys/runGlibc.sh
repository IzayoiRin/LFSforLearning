# !/bin/bash

BUILD_TEMP_ROOT="build/"
CONFIGURE_FILE="configure"
PATCH_FILE="glibc-2.31-fhs-1.patch"

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="GlibcInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"

ESS_FILES="${0%/*}/ess/"
TIME_ZONE_PACK="/sources/tzdata2019c.tar.gz"
LOCAL_TZ="Asia/Shanghai"


clear_temp(){
	echo "Cleaning Temps ... ..."
	cd ../;dir=`pwd`;cd ../
	echo "remove ${dir}"
	rm -rf $dir
	pwd
}


symlink_for_LSB(){
	case $(uname -m) in
		i?86) ln -sfv ld-linux.so.2 /lib/ld-lsb.so.3 ;;
		x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64
				ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3 ;;
	esac
}


min_locales_respond_difflang(){
	# installed using localedef
	mkdir -pv /usr/lib/locale
	localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
	localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
	localedef -i de_DE -f ISO-8859-1 de_DE
	localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
	localedef -i de_DE -f UTF-8 de_DE.UTF-8
	localedef -i el_GR -f ISO-8859-7 el_GR
	localedef -i en_GB -f UTF-8 en_GB.UTF-8
	localedef -i en_HK -f ISO-8859-1 en_HK
	localedef -i en_PH -f ISO-8859-1 en_PH
	localedef -i en_US -f ISO-8859-1 en_US
	localedef -i en_US -f UTF-8 en_US.UTF-8
	localedef -i es_MX -f ISO-8859-1 es_MX
	localedef -i fa_IR -f UTF-8 fa_IR
	localedef -i fr_FR -f ISO-8859-1 fr_FR
	localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
	localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
	localedef -i it_IT -f ISO-8859-1 it_IT
	localedef -i it_IT -f UTF-8 it_IT.UTF-8
	localedef -i ja_JP -f EUC-JP ja_JP
	localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS 2> /dev/null || true
	localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
	localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
	localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
	localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
	localedef -i zh_CN -f GB18030 zh_CN.GB18030
	localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
	}


additional_install(){
	echo "Installing conf & runtime for nscd ... ..."
	cp -v ../nscd/nscd.conf /etc/nscd.conf
	mkdir -pv /var/cache/nscd

	echo -e "! Install locale set for test:\n\t${1} Mod acrossing Lacaledef"
	if [ "$1" == "--min" ];then
		# install the minimum set of locales necessary for the optimal coverage of tests
		min_locales_respond_difflang 1> /dev/null 2>> $LOGS
	else
		# install all locales listed in the glibc-2.31/localedata/SUPPORTED
		make localedata/install-locales 1> /dev/null 2>> $LOGS
	fi
}


iinstall(){
	pch="../${PATCH_FILE}"
	if [ ! -f $pch ];then
		echo "Can't find ${pch}"
		return 1
	fi
	echo "Patch Self ... ..."
	# pathc to store runtime data in /var/db
	patch -Np1 -i $pch 1> /dev/null 2> $LOGS
	echo "Mapping symlink for LSB ... ..."
	symlink_for_LSB

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
	# CC: gcc record refer in /tools after compilation to avoid invalid paths in debugging
	# werror： disable GCC warning thought test
	# stack: enable to increase sys security by checking for buffer overflows
	# headers: with /usr/include instead of /tools/include guiding sys find linux api header ### linuxapi: cp -r usr/include/* /usr/include ###
	# libc_cv_slibdir: correct lib for sys using /lib instead of /lib64
	CC="gcc -ffile-prefix-map=/tools=/usr" \
	../configure --prefix=/usr \
	--disable-werror \
	--enable-kernel=3.2 \
	--enable-stack-protector=strong \
	--with-headers=/usr/include \
	libc_cv_slibdir=/lib \
	1> /dev/null 2>> $LOGS

	echo "Making ... ..."
	# compile package 
	make 1> /dev/null 2>> $LOGS

	# critical necessary test, do not skip
 	echo "Expect Testing ... ..."
 	# needed to run test in chroot env then overwrittern in install phase
 	echo "! Map few temp syslink for test."
	case $(uname -m) in
		i?86) ln -sfnv $PWD/elf/ld-linux.so.2 /lib ;;
		x86_64) ln -sfnv $PWD/elf/ld-linux-x86-64.so.2 /lib ;;
	esac
    make check 1> /dev/null 2>> $LOGS

    echo "! Fix some problems."
    # Prevent this warning causing the absence of /etc/ld.so.conf.
    touch /etc/ld.so.conf
    # skip an unneeded sanity check that fails in the LFS partial environment
    sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

	echo "Make-installing ... ..."
	# install compiled package 
	make install 1> /dev/null 2>> $LOGS

	additional_install
	return 0	
}


add_time_zone(){
	if [ ! -f ${TIME_ZONE_PACK} ];then
		echo "Can't find ${TIME_ZONE_PACK}"
		return 1
	fi
	tar -xf $TIME_ZONE_PACK
	
	ZONEINFO=/usr/share/zoneinfo
	mkdir -pv $ZONEINFO/{posix,right}

	for tz in etcetera southamerica northamerica europe africa \
	antarctica asia australasia backward pacificnew systemv; do
		# create posix time zones without leap seconds
		zic -L /dev/null -d $ZONEINFO ${tz}
		zic -L /dev/null -d $ZONEINFO/posix ${tz}
		# create right time zones with leap seconds
		zic -L leapseconds -d $ZONEINFO/right ${tz}
	done

	cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
	# create the posixrules file using NY causing daylight saving time rules
	zic -d $ZONEINFO -p America/New_York
	unset ZONEINFO

	echo "! Determin local time zone."
	# using `tzselect` get right time zone
	ln -sfv /usr/share/zoneinfo/${LOCAL_TZ} /etc/localtime
}


gconf(){
	# solve Glibc defaults do not work well in a networked environment
	echo "! Imporve network capability ."
	cp -v ${ESS_FILES}nsswitch.conf /etc/nsswitch.conf
	echo "! set up the time zone data."
	add_time_zone
	# dl /lib/ld-linux.so.2 search /lib & /usr/lib and find other lib guiding by /etc/ld.so.conf
	# /usr/local/lib & /opt/lib common additional lib
	echo "! Set dynamic loader/"
	cp -v ${ESS_FILES}ld.so.conf /etc/ld.so.conf
	mkdir -pv /etc/ld.so.conf.d
}


main(){
	echo -e "Glibc\n\r\tApproximate Build Time: 19 SBU\n\r\tSpace: 5.5G\n\r\tVersion: 2.31"
	echo ">>>>> Begin to COMPILE >>>>>"
	iinstall $*
	if [ $? != 0 ];then
		exit 1
	fi
	gconf
	clear_temp
}


main $*
