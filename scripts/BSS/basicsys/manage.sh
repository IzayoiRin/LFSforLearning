SOURCES="/sources/"
SETUP_ENV="/chroot/"


main(){
    cd $SOURCES
    pwd
    package=`echo "${1}" | cut -d"-" -f1`
    dir=`ls -F | grep '/$' | grep $package`
    if [ ! -d "$dir" ];then
        echo "Extract from source: ${1} >> ${package}"
        tar -xf $1
        dir=`ls -F | grep '/$' | grep $package`
    fi
    cd ${SOURCES}${dir}
    pwd
    p=`echo $* | cut -d" " -f3-`
    bash ${0%/*}/run${2}.sh $p 
}


date
time main $*
