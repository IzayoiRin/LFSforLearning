CHAROOT="${LFS}/chroot/"
INSTALLER="installer.sh"


cp_source(){
    if [ ! -d $CHAROOT ];then
        sudo mkdir -v $CHAROOT
    fi
    for i in `ls -F | grep "/"`
    do
        echo "copy: ${i} ---> ${CHAROOT}"
    done
    sudo cp -r */ $CHAROOT
    sudo cp -v $INSTALLER $CHAROOT
}


main(){
    if [ "$1" == "--init" ];then
        cp_source
    elif [ "$1" == "--debug" ];then
        cp_source
    fi

    bash pre_basic_sys.sh $*
}


main $*
