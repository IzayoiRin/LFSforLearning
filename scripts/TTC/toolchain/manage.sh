SOURCES="${LFS}/sources"
SETUP_ENV=`pwd`
RUNSH="${0}"

main(){
    cd $SOURCES
    pwd
    package=${1%%\.tar.*}
    dir=`ls -F | grep '/$' | grep $package`
    if [ ! -d "$dir" ];then
        echo "Extract from source: ${1} >> ${package}"
        tar -xf $1
        dir=`ls -F | grep '/$' | grep $package`
    fi
    cd ${SOURCES}${dir}
    pwd
    f="`echo $0 | cut -d"/" -f1`/run${2}.sh"
    p=`echo $* | cut -d" " -f3-`
    bash ${0%/*}/run${2}.sh $p 
}


date
time main $*
