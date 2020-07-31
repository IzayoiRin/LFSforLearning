SOURCES="/sources/"
SETUP_ENV="/chroot/"
RUNSH="${SETUP_ENV}basicsys"


basicsys1(){
    bash ${RUNSH}/manage.sh linux-5.5.3.tar.xz LinuxAPI
    bash ${RUNSH}/manage.sh man-pages-5.05.tar.xz Manpages
}


main(){
    cd $SOURCES
    echo "################# STEP 1 #####################"
    basicsys1
}


main
