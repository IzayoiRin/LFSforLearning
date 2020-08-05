SOURCES="/sources/"
SETUP_ENV="/chroot/"
RUNSH="${SETUP_ENV}basicsys"

LOGS_DIR=".logs/"


basicsys4(){
	echo bash ${RUNSH}/manage.sh acl-2.2.53.tar.gz Acl --only-test
}


main(){
    cd $SOURCES
    echo "################# STEP 4 #####################"
    basicsys4
}


main
