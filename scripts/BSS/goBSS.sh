CHAROOT="${LFS}/chroot"
INSTALLER="installer.sh"


main(){
    if [ ! -d $CHAROOT ];then
        sudo mkdir -v $CHAROOT
    fi
    for i in `ls -F | grep "/"` 
    do
        echo "copy: ${i} ---> ${CHAROOT}"
    done
    sudo cp -r */ $CHAROOT
    sudo cp -v $INSTALLER $CHAROOT
    bash pre_basic_sys.sh $*
}


main $*
