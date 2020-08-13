SOURCES="/sources/"
SETUP_ENV="/chroot/"
RUNSH="${SETUP_ENV}basicsys"


main(){
	cd $SOURCES
	bash ${RUNSH}/manage.sh lfs-bootscripts-20191031.tar.xz LFS-bootscripts
}

main
