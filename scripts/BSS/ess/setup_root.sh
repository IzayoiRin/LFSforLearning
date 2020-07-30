SETUP_ENV="/chroot"
ESS_FILES="${SETUP_ENV}/ess"

init_std_dirtree(){
    echo "<<< based on the Filesystem Hierarchy Standard >>>"
    mkdir -pv /{bin,boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}
    mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}
    # not just anybody can enter the /root directory
    install -dv -m 0750 /root
    # any user can write to the /tmp and /var/tmp directories
    install -dv -m 1777 /tmp /var/tmp
    mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
    mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
    mkdir -v /usr/{,local/}share/{misc,terminfo,zoneinfo}
    mkdir -v /usr/libexec
    mkdir -pv /usr/{,local/}share/man/man{1..8}
    mkdir -v /usr/lib/pkgconfig

    case $(uname -m) in
        x86_64) mkdir -v /lib64 ;;
    esac

    mkdir -v /var/{log,mail,spool}
    ln -sv /run /var/run
    ln -sv /run/lock /var/lock
    mkdir -pv /var/{opt,cache,lib/{color,misc,locate},local}
}


map_ess_symlinks(){
    # tool/bin/* symlinks----> bin/*
    # bash: sh scrpit
    # cat: glibc conf script
    # dd: usr/bin/libtool
    # echo: glibc test
    # ln: /usr/lib/perl5/5.30.1/<target-triplet>/Config_heavy.pl
    # pwd: conf script
    # rm: /usr/lib/perl5/5.30.1/<target-triplet>/Config_heavy.pl
    # stty: Expect, binutils, gcc test
    ln -sv /tools/bin/{bash,cat,chmod,dd,echo,ln,mkdir,pwd,rm,stty,touch} /bin
    # tool/bin/* symlinks----> usr/bin/*
    # env: packages build procedures
    # install: usr/bin/bash/Makefile.inc
    # perl: Perl scripts
    ln -sv /tools/bin/{env,install,perl,printf} /usr/bin
    # glibc's pthreads lib
    ln -sv /tools/lib/libgcc_s.so{,.1} /usr/lib
    # glibc test and cpp support in gmp
    ln -sv /tools/lib/libstdc++.{a,so{,.6}} /usr/lib
    # sh script
    ln -sv bash /bin/sh
    #  maintains mounted file systems exposed via /proc
    ln -sv /proc/self/mounts /etc/mtab
}


init_ess_files(){
    # x: placeholder
    cp -v ${ESS_FILES}/passwd /etc/passwd
    cp -v ${ESS_FILES}/group /etc/group
    touch /var/log/{btmp,lastlog,faillog,wtmp}
    chgrp -v utmp /var/log/lastlog
    chmod -v 664 /var/log/lastlog
    chmod -v 600 /var/log/btmp
}


main(){
    echo "###### Initial Standard Dir Tree ######"
    init_std_dirtree
    echo "####### Map Essential Symlinks ########"
    map_ess_symlinks
    echo "####### Initial Essential Files #######"
    init_ess_files
}


main
