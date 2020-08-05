# !/bin/bash

SYSFORMT_X86_64="x86_64"
BUILD_TEMP_ROOT="build/"
CONFIGURE_FILE="configure"

LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="GccInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


set_default_lib_name(){
	case $(uname -m) in
		${SYSFORMT_X86_64})
		sed -e '/m64=/s/lib64/lib/' \
		-i.orig gcc/config/i386/t-linux64
		;;
	esac
}


icheck(){
	echo "Expect Testing ... ..."
	# test suite is known to exhaust the stack, so increase the stack size
	ulimit -s 32768
	# non-privileged user do not stop at errors
	echo "! Change ownership to <nobody>."
	chown -R nobody .
	su nobody -s /bin/bash -c "PATH=$PATH make -k check" \
	1> /dev/null 2>> $LOGS

	../contrib/test_summary | grep -A7 Summ
}


clear_temp(){
	echo "Cleaning Temps ... ..."
	cd ../;dir=`pwd`;cd ../
	echo "remove ${dir}"
	rm -rf $dir
	pwd
}


iinstall(){
	# change the default directory name for 64-bit libraries
	set_default_lib_name
	echo "! Fix a problem cause by glibc."
	sed -e '1161 s|^|//|' \
	-i libsanitizer/sanitizer_common/sanitizer_platform_limits_posix.cc

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
	# sed: prevents a hard-coded path to /tools/bin/sed
	# zlib: with to link sys zlib lib instead of internal one
	SED=sed \
	$conf \
	--prefix=/usr \
	--enable-languages=c,c++ \
	--disable-multilib \
	--disable-bootstrap \
	--with-system-zlib \
	1> /dev/null 2> $LOGS

	echo "Making ... ..."
	make 1> /dev/null 2>> $LOGS
	
	# critical necessary test, do not skip
	icheck

	echo "Make-installing ... ..."	
	# Install the package and remove an unneeded directory
	make install 1> /dev/null 2>> $LOGS
	rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/9.2.0/include-fixed/bits/

	echo "! Change the ownership to root."
	chown -v -R root:root \
	/usr/lib/gcc/*linux-gnu/9.2.0/include{,-fixed}
	
	echo "! Create a symlink required by the FHS."
	ln -sv ../usr/bin/cpp /lib

	echo "! Name cc to call the C compiler."
	ln -sv gcc /usr/bin/cc

	# Add a compatibility symlink to enable building programs with Link Time Optimization
	echo "! Add Link Time Optimization."
	install -v -dm755 /usr/lib/bfd-plugins
	ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/9.2.0/liblto_plugin.so \
	/usr/lib/bfd-plugins/
}


final_check(){
	echo "CK1 Verify basic functions:"
	echo 'int main(){}' > dummy.c
	cc dummy.c -v -Wl,--verbose &> dummy.log
	readelf -l a.out | grep ': /lib'

	# setup to use the correct start files
	echo "CK2 Verify glibc start files:"
	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log

	# compiler is searching for the correct header files
	echo "CK3 Verify compiler header files:"
	grep -B4 '^ /usr/include' dummy.log

	# new linker used with the correct search paths
	echo "CK4 Verify linker search paths:"
	grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

	# make sure using the correct libc
	echo "CK5 Verify libc:"
	grep "/lib.*/libc.so.6 " dummy.log

	# make sure GCC using the correct dynamic linker
	echo "CK6 Verify GCC dynamic linker:"
	grep found dummy.log

	# clean up the test files
	rm -v dummy.c a.out dummy.log
}


main(){
	echo -e "GCC: \n\r\tApproximate Build Time: 88 SBU\n\r\tSpcae: 4.2G\n\r\tVersion: 9.2.0"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall
    echo ">>>>> Self Checking >>>>>"
    final_check
    echo "! Move a misplaced file."
    mkdir -pv /usr/share/gdb/auto-load/usr/lib
	mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
	clear_temp
}


main
