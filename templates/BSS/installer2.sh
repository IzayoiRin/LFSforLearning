SOURCES="/sources/"
SETUP_ENV="/chroot/"
RUNSH="${SETUP_ENV}basicsys"
SUCE_CALL_BACK_FLG=200

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
    bash ${RUNSH}/manage.sh check-0.14.0.tar.gz Check --test
    bash ${RUNSH}/manage.sh diffutils-3.7.tar.xz Diffutils --test
    bash ${RUNSH}/manage.sh gawk-5.0.1.tar.xz Gawk --test
    bash ${RUNSH}/manage.sh findutils-4.7.0.tar.xz Findutils --test
    bash ${RUNSH}/manage.sh groff-1.22.4.tar.gz Groff A4
    bash ${RUNSH}/manage.sh grub-2.04.tar.xz GRUB
    bash ${RUNSH}/manage.sh less-551.tar.gz Less
    bash ${RUNSH}/manage.sh gzip-1.10.tar.xz Gzip --test
    bash ${RUNSH}/manage.sh zstd-1.4.4.tar.gz Zstd
    bash ${RUNSH}/manage.sh iproute2-5.5.0.tar.xz IPRoute
    bash ${RUNSH}/manage.sh kbd-2.2.0.tar.xz Kbd --test
    bash ${RUNSH}/manage.sh libpipeline-1.5.2.tar.gz Libpipeline --test
    bash ${RUNSH}/manage.sh make-4.3.tar.gz Make --test
    bash ${RUNSH}/manage.sh patch-2.7.6.tar.xz Patch --test
    bash ${RUNSH}/manage.sh man-db-2.9.0.tar.xz Man-DB --test
    bash ${RUNSH}/manage.sh tar-1.32.tar.xz Tar --test
    bash ${RUNSH}/manage.sh texinfo-6.7.tar.xz Texinfo --test
    bash ${RUNSH}/manage.sh vim-8.2.0190.tar.gz Vim --test
    bash ${RUNSH}/manage.sh procps-ng-3.3.15.tar.xz Procps --test
    bash ${RUNSH}/manage.sh util-linux-2.35.1.tar.xz UtilL --test
    bash ${RUNSH}/manage.sh e2fsprogs-1.45.5.tar.gz E2fsprogs --test
    bash ${RUNSH}/manage.sh sysvinit-2.96.tar.xz Sysvinit
    bash ${RUNSH}/manage.sh eudev-3.2.9.tar.gz Eudev --test
}


__debug_symbols__(){
    echo "Debugging symbols ... ..."
    save_lib="ld-2.31.so libc-2.31.so libpthread-2.31.so libthread_db-1.0.so"
    cd /lib; pwd

    for LIB in $save_lib; do
        objcopy --only-keep-debug $LIB $LIB.dbg
        strip --strip-unneeded $LIB
        objcopy --add-gnu-debuglink=$LIB.dbg $LIB
    done

    save_usrlib="libquadmath.so.0.0.0 libstdc++.so.6.0.27
    libitm.so.1.0.0 libatomic.so.1.2.0"
    cd /usr/lib; pwd

    for LIB in $save_usrlib; do
        objcopy --only-keep-debug $LIB $LIB.dbg
        strip --strip-unneeded $LIB
        objcopy --add-gnu-debuglink=$LIB.dbg $LIB
    done

    unset LIB save_lib save_usrlib
}


main(){
    cd $SOURCES
    echo "################# STEP 4 #####################"
    basicsys4
    basicsys5
    echo "################# STRIP1  #####################"
    __debug_symbols__ 2>${SOURCES}${LOGS_DIR}"StripLogs2.log"
    return ${SUCE_CALL_BACK_FLG}
}


main
