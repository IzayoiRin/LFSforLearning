SOURCES="/sources/"
SETUP_ENV="/chroot/"
RUSH="${SETUP_ENV}basicsys"


basicsys1(){
	bash ${RUNSH}/manage.sh linux-5.5.3.tar.xz LinuxAPI
}


main(){
	cd $SOURCES
	echo "################# STEP 1 #####################"
	basicsys1
}


main
