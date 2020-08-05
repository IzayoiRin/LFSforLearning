SOURCES="/sources/"
SETUP_ENV="/chroot/"


main(){
    cd $SOURCES
    pwd
    package=${1%%\.tar.*}
    dir=`ls -F | grep '/$' | grep $package`
    if [ ! -d "$dir" ];then
        echo "Extract from source: ${1} >> ${package}"
        mkdir ${package} && tar -xf $1 -C ./${package} --strip-components 1
        dir=${package}
    fi
    cd ${SOURCES}${dir}
    pwd
    p=`echo $* | cut -d" " -f3-`
    bash ${0%/*}/run${2}.sh $p 
}


date
time main $*
