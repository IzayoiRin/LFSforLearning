SOURCES="/sources/"
LOGS_DIR=".logs/"


__strip__(){
    echo "Stripping ... ..."
    /tools/bin/find /usr/lib -type f -name \*.a \
    -exec /tools/bin/strip --strip-debug {} ';'
    /tools/bin/find /lib /usr/lib -type f \( -name \*.so* -a ! -name \*dbg \) \
    -exec /tools/bin/strip --strip-unneeded {} ';'
    /tools/bin/find /{bin,sbin} /usr/{bin,sbin,libexec} -type f \
    -exec /tools/bin/strip --strip-all {} ';'

    echo "Cleaning up extra files left ... ..."
    rm -rf /tmp/*
}

__unstall__(){
	echo "! Remove Temp Toolchains."
	rm -rf /tools

	echo "! Remove unsuppressed statci libs."
	rm -vf /usr/lib/lib{bfd,opcodes}.a
	rm -vf /usr/lib/libbz2.a
	rm -vf /usr/lib/lib{com_err,e2p,ext2fs,ss}.a
	rm -vf /usr/lib/libltdl.a
	rm -vf /usr/lib/libfl.a
	rm -vf /usr/lib/libz.a

	echo "! Remove necessary files."
	find /usr/lib /usr/libexec -name \*.la -delete
}


main(){
	echo "################# STRIP2  #####################"
	__strip__ 2>> ${SOURCES}${LOGS_DIR}"StripLogs2.log"
}


main
