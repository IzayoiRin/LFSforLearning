CHAROOT="${LFS}/chroot/"
EXCECUTORS="$(dirname $0)/*installer*.sh"
PREXEC="$(dirname $0)/pre_basic_sys.sh"
EXEC_DIR="$(dirname $0)/*/"


cp_source(){
    if [ ! -d ${CHAROOT} ];then
        sudo mkdir -v ${CHAROOT}
    fi
    for i in `ls -F | grep "/"`
    do
        echo "copy: ${i} ---> ${CHAROOT}"
    done
    sudo cp -r ${EXEC_DIR} ${CHAROOT}
    sudo cp -v ${EXCECUTORS} ${CHAROOT}
}


main(){
    p=$*
    if [[ $(echo $p | grep -o 'cp') ]];then
        p=$(echo $p | sed 's/--cp//g')
        cp_source
    fi
    bash ${PREXEC} $p
}



main $*
