SOURCES=$LFS/sources


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
    cd $LFS/sources/$dir
    pwd
    f="`echo $0 | cut -d"/" -f1`/run${2}.sh"
    p=`echo $* | cut -d" " -f3-`
    bash $SOURCES/$f $p 
}


date
time main $*
