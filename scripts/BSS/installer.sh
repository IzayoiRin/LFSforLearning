SOURCES="/sources/"
SETUP_ENV="/chroot/"
RUNSH="${SETUP_ENV}basicsys"


basicsys1(){
    bash ${RUNSH}/manage.sh linux-5.5.3.tar.xz LinuxAPI
    bash ${RUNSH}/manage.sh man-pages-5.05.tar.xz Manpages
    bash ${RUNSH}/manage.sh glibc-2.31.tar.xz Glibc --min
}


adj_check(){
	# ensure that the basic functions (compiling and linking) 
	echo "CK1 Verify basic functions:"
	echo 'int main(){}' > dummy.c
	cc dummy.c -v -Wl,--verbose &> dummy.log
	readelf -l a.out | grep ': /lib'

	# make sure using the correct start files
	echo "CK2 Verify glibc start files:"
	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log

	# compiler is searching for the correct header files
	echo "CK3 Verify compiler header files:"
	grep -B1 '^ /usr/include' dummy.log

	# new linker used with the correct search paths
	echo "CK4 Verify linker search paths:"
	grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

	# make sure using the correct libc
	echo "CK5 Verify libc:"
	grep "/lib.*/libc.so.6 " dummy.log

	# make sure GCC using the correct dynamic linker
	echo "CK4 Verify GCC dynamic linker:"
	grep found dummy.log

	# clean up the test files
	rm -v dummy.c a.out dummy.log
}


adjust(){
	echo ">>>>> Adjust Toolchains >>>>>"
	# final C libraries have been installed, adjust new link
    echo "! Adjust TTC with NEW linker."
    mv -v /tools/bin/{ld,ld-old}
    mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
    mv -v /tools/bin/{ld-new,ld}
    ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld
    # amend the GCC specs file so that it points to the new dynamic linker.
    echo "! Modify GCC pointing to NEW dynamic linker."
    # delete all instances of /tools seting correct path to dl
    # ajdust gcc specs file linking correct headers & glicv start files
	gcc -dumpspecs | sed -e 's@/tools@@g' \
	-e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
	-e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' > \
	`dirname $(gcc --print-libgcc-file-name)`/specs

	echo ">>>>> Self Checking >>>>>"
	adj_check
}


basicsys2(){
	bash ${RUNSH}/manage.sh zlib-1.2.11.tar.xz Zlib --test
	bash ${RUNSH}/manage.sh bzip2-1.0.8.tar.gz Bzip
	bash ${RUNSH}/manage.sh xz-5.2.4.tar.xz Xz --test
	bash ${RUNSH}/manage.sh file-5.38.tar.gz File --test
	bash ${RUNSH}/manage.sh readline-8.0.tar.gz Readline
	bash ${RUNSH}/manage.sh m4-1.4.18.tar.xz M4 --test
	bash ${RUNSH}/manage.sh bc-2.5.3.tar.gz Bc --test
	bash ${RUNSH}/manage.sh binutils-2.34.tar.xz Binutils
}


main(){
    cd $SOURCES
    echo "################# STEP 1 #####################"
    basicsys1
    echo "################# ADJUST #####################"
    adjust
    echo "################# STEP 2 #####################"
    basicsys2
}


main
