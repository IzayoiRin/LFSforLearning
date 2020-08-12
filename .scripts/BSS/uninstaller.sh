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


main(){
	echo "################# STRIP2  #####################"
	__strip__ 2>> ${SOURCES}${LOGS_DIR}"StripLogs2.log"
}


main
