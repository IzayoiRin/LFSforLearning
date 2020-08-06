SOURCES="/sources/"
SETUP_ENV="/chroot/"
RUNSH="${SETUP_ENV}basicsys"

LOGS_DIR=".logs/"


basicsys4(){
	bash ${RUNSH}/manage.sh libtool-2.4.6.tar.xz Libtool --test 4
	bash ${RUNSH}/manage.sh gdbm-1.18.1.tar.gz GDBM --test
	bash ${RUNSH}/manage.sh gperf-3.1.tar.gz Gperf --test 1
	bash ${RUNSH}/manage.sh expat-2.2.9.tar.xz Expat --test
	bash ${RUNSH}/manage.sh inetutils-1.9.4.tar.xz Inetutils --test
	bash ${RUNSH}/manage.sh perl-5.30.1.tar.xz Perl --test
	bash ${RUNSH}/manage.sh XML-Parser-2.46.tar.gz XMLparser --test
	bash ${RUNSH}/manage.sh intltool-0.51.0.tar.gz Intltool --test
	bash ${RUNSH}/manage.sh autoconf-2.69.tar.xz Autoconf --test
	bash ${RUNSH}/manage.sh automake-1.16.1.tar.xz Automake --test 4
	bash ${RUNSH}/manage.sh kmod-26.tar.xz Kmod
	bash ${RUNSH}/manage.sh gettext-0.20.1.tar.xz Gettext --test
	bash ${RUNSH}/manage.sh elfutils-0.178.tar.bz2 Libelf --test
	bash ${RUNSH}/manage.sh libffi-3.3.tar.gz Libffi --test
	bash ${RUNSH}/manage.sh openssl-1.1.1d.tar.gz OpenSSL --test
	bash ${RUNSH}/manage.sh Python-3.8.1.tar.xz Python
	bash ${RUNSH}/manage.sh ninja-1.10.0.tar.gz Ninja --test 4
	bash ${RUNSH}/manage.sh meson-0.53.1.tar.gz Meson
	bash ${RUNSH}/manage.sh coreutils-8.31.tar.xz Coreutils --test
    bash ${RUNSH}/manage.sh acl-2.2.53.tar.gz Acl --only-test
}


basicsys5(){

}


main(){
    cd $SOURCES
    echo "################# STEP 4 #####################"
    basicsys4
    basicsys5
}


main
