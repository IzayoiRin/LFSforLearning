SOURCES_DIR="sources/"
SROOT="${LFS}/${SOURCES_DIR}"
LOGS_DIR=".logs/"
RUNSH="$(dirname $0)/toolchain"
SU="$(dirname $0)/ess/su.ini"


if [ ! -d ${SROOT}${LOGS_DIR} ];then
	mkdir -v ${SROOT}${LOGS_DIR}
fi

toolchain1(){
	echo "################# STEP 1 #####################"
	@for:i:step1:: bash ${RUNSH}/manage.sh {{i.package}} {{i.name}} {{i.params}} ::
	# bash ${RUNSH}/manage.sh binutils-2.34.tar.xz Binutils p1
	# bash ${RUNSH}/manage.sh gcc-9.2.0.tar.xz Gcc -xc p1
	# bash ${RUNSH}/manage.sh linux-5.5.3.tar.xz LinuxAPI
	# bash ${RUNSH}/manage.sh glibc-2.31.tar.xz Glibc
	# bash ${RUNSH}/manage.sh gcc-9.2.0.tar.xz Libstdcpp
	# bash ${RUNSH}/manage.sh binutils-2.34.tar.xz Binutils p2
	# bash ${RUNSH}/manage.sh gcc-9.2.0.tar.xz Gcc -c p2	
}


toolchain2(){
	echo "################# STEP 2 #####################"
	@for:j:step2:: bash ${RUNSH}/manage.sh {{j.package}} {{j.name}} {{j.params}} ::
	# bash ${RUNSH}/manage.sh tcl8.6.10-src.tar.gz  Tcl --test
	# bash ${RUNSH}/manage.sh expect5.45.4.tar.gz Expect --test
	# bash ${RUNSH}/manage.sh dejagnu-1.6.2.tar.gz DejaGNU --test
	# bash ${RUNSH}/manage.sh m4-1.4.18.tar.xz M4 --test
	# bash ${RUNSH}/manage.sh ncurses-6.2.tar.gz Ncurses	
}


toolchain3(){
	echo "################# STEP 3 #####################"
	@for:i:step3:: bash ${RUNSH}/manage.sh {{i.package}} {{i.name}} {{i.params}} ::
	# bash ${RUNSH}/manage.sh bash-5.0.tar.gz Bash --test
	# bash ${RUNSH}/manage.sh bison-3.5.2.tar.xz Bison --test
	# bash ${RUNSH}/manage.sh bzip2-1.0.8.tar.gz Bzip
	# bash ${RUNSH}/manage.sh coreutils-8.31.tar.xz Coreutils --test
	# bash ${RUNSH}/manage.sh diffutils-3.7.tar.xz Diffutils --test
	# bash ${RUNSH}/manage.sh file-5.38.tar.gz File --test
	# bash ${RUNSH}/manage.sh findutils-4.7.0.tar.xz Findutils --test
	# bash ${RUNSH}/manage.sh gawk-5.0.1.tar.xz Gawk --test
	# bash ${RUNSH}/manage.sh gettext-0.20.1.tar.xz Gettext
	# bash ${RUNSH}/manage.sh grep-3.4.tar.xz Grep --test
	# bash ${RUNSH}/manage.sh gzip-1.10.tar.xz Gzip --test
	# bash ${RUNSH}/manage.sh make-4.3.tar.gz Make --test
	# bash ${RUNSH}/manage.sh patch-2.7.6.tar.xz Patch --test
	# bash ${RUNSH}/manage.sh perl-5.30.1.tar.xz Perl 
	# bash ${RUNSH}/manage.sh Python-3.8.1.tar.xz Python
	# bash ${RUNSH}/manage.sh sed-4.8.tar.xz Sed --test
	# bash ${RUNSH}/manage.sh tar-1.32.tar.xz Tar --test
	# bash ${RUNSH}/manage.sh texinfo-6.7.tar.xz Texinfo --test
	# bash ${RUNSH}/manage.sh xz-5.2.4.tar.xz Xz --test	
}


__strip__(){
	echo "################# STRIP  #####################"
	echo "! Remove unneeded debugging symbols ~70M."
	# --strip-unneeded destroyed lib
	strip --strip-debug /tools/lib/*
	/usr/bin/strip --strip-unneeded /tools/{,s}bin/*
	echo "! Remove documentation."
	rm -rf /tools/{,share}/{info,man,doc}
	echo "! Remove unneeded files."
	find /tools/{lib,libexec} -name \*.la -delete
}


__chown__(){
	echo "################# CHOWN  #####################"
	expect ${SU}
}


main(){
	toolchain1
	toolchain2
	toolchain3
	__strip__ 2>${SROOT}${LOGS_DIR}"StripLogs.log"
}


main
