SOURCES_DIR="sources/"
SROOT="${LFS}/${SOURCES_DIR}"
LOGS_DIR=".logs/"
RUNSH=`pwd`"/toolchain"


if [ ! -d ${SROOT}${LOGS_DIR} ];then
	echo mkdir ${SROOT}${LOGS_DIR}
fi

toolchain1(){
	bash ${RUNSH}/manage.sh binutils-2.34.tar.xz Binutils p1
	bash ${RUNSH}/manage.sh gcc-9.2.0.tar.xz Gcc -xc p1
	bash ${RUNSH}/manage.sh linux-5.5.3.tar.xz LinuxAPI
	bash ${RUNSH}/manage.sh glibc-2.31.tar.xz Glibc
	bash ${RUNSH}/manage.sh gcc-9.2.0.tar.xz Libstdcpp
	bash ${RUNSH}/manage.sh binutils-2.34.tar.xz Binutils p2
	bash ${RUNSH}/manage.sh gcc-9.2.0.tar.xz Gcc -c p2	
}


toolchain2(){
	bash ${RUNSH}/manage.sh tcl8.6.10-src.tar.gz  Tcl --test
	bash ${RUNSH}/manage.sh expect-5.45.4.tar.gz Expect --test
	bash ${RUNSH}/manage.sh dejagnu-1.6.2.tar.gz DejaGNU --test
	bash ${RUNSH}/manage.sh m4-1.4.18.tar.xz M4 --test
	bash ${RUNSH}/manage.sh ncurses-6.2.tar.gz Ncurese	
}


toolchain3(){
	bash ${RUNSH}/manage.sh bash-5.0.tar.gz Bash --test
	bash ${RUNSH}/manage.sh bison-3.5.2.tar.xz Bison --test
	bash ${RUNSH}/manage.sh bzip2-1.0.8.tar.gz Bzip
	bash ${RUNSH}/manage.sh coreutils-8.31.tar.xz Coreutils --test
	bash ${RUNSH}/manage.sh diffutils-3.7.tar.xz Diffutils --test
	bash ${RUNSH}/manage.sh file-5.38.tar.gz File --test
	bash ${RUNSH}/manage.sh findutils-4.7.0.tar.xz Findutils --test
	bash ${RUNSH}/manage.sh gawk-5.0.1.tar.xz Gawk --test
	bash ${RUNSH}/manage.sh gettext-0.20.1.tar.xz Gettext
	bash ${RUNSH}/manage.sh grep-3.4.tar.xz Grep --test
	bash ${RUNSH}/manage.sh gzip-1.10.tar.xz Gzip --test
	bash ${RUNSH}/manage.sh make-4.3.tar.gz Make --test
	bash ${RUNSH}/manage.sh patch-2.7.6.tar.xz Patch --test
	bash ${RUNSH}/manage.sh perl-5.30.1.tar.xz Perl 
	bash ${RUNSH}/manage.sh Python-3.8.1.tar.xz Python
	bash ${RUNSH}/manage.sh sed-4.8.tar.xz Sed --test
	bash ${RUNSH}/manage.sh tar-1.32.tar.xz Tar --test
	bash ${RUNSH}/manage.sh texinfo-6.7.tar.xz Texinfo --test
	bash ${RUNSH}/manage.sh xz-5.2.4.tar.xz Xz --test	
}


__strip__(){
    echo "! Remove unneeded debugging symbols ~70M."
    # --strip-unneeded destroyed lib
    strip --strip-debug /tools/lib/*
    /usr/bin/strip --strip-unneeded /tools/{,s}bin/*
    echo "! Remove documentation."
    rm -rf /tools/{,share}/{info,man,doc}
    echo "! Remove unneeded files."
    find /tools/{lib,libexec} -name \*.la -delete
}


main(){
	echo "################# STEP 1 #####################"
	toolchain1
	echo "################# STEP 2 #####################"
	toolchain2
	echo "################# STEP 3 #####################"
	toolchain3
    echo "################# STRIP  #####################"
    __strip__ 1>/dev/null 2>${SROOT}${LOGS_DIR}"StripLogs.log"
}


main
