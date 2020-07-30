SOURCES_DIR="sources/"
SROOT="${LFS}/${SOURCES_DIR}"
LOGS_DIR=".logs/"
RUNSH="basicsys/"

basicsys1(){
	bash ${RUNSH}/manage.sh linux-5.5.3.tar.xz LinuxAPI
	bash ${RUNSH}/manage.sh linux-5.5.3.tar.xz Manpages
}


main(){
	bash ./pre_basic_sys.sh
	cd $SROOT
	echo "################# STEP 1 #####################"
}


main
