# !bin/bash

CONFIGURE_FILE="configure.py"
LOG_PREFIX="/sources/.logs/"
LOGS_NAME="NinjaInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    conf="./${CONFIGURE_FILE}"
    if [ ! -f $conf ];then
        echo "Can't find ${conf}"
        return 1
    fi

    n=4;if [ $2 ];then n=${2};fi
    echo -e "\t-cores: ${n}"
    export NINJAJOBS=${n}

    echo "! Add the capability useing NINJAJOBS."
    sed -i '/int Guess/a \
    int j = 0;\
    char* jobs = getenv( "NINJAJOBS" );\
    if ( jobs != NULL ) j = atoi( jobs );\
    if ( j > 0 ) return j;\
' src/ninja.cc

    echo "Configuring ... ..."
    python3 $conf --bootstrap \
    1> /dev/null 2> $LOGS

    if [ "${1}" == "--test" ];then
        echo "Expect Testing ... ..."
        ./ninja ninja_test /
        1> /dev/null 2>> $LOGS

        ./ninja_test --gtest_filter=-SubprocessTest.SetWithLots /
        1> /dev/null 2>> $LOGS
    fi

    # install compiled package 
    echo "Make-installing ... ..."
    install -mv755 ninja /usr/bin/
    install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
    install -vDm644 misc/zsh-completion /usr/share/zsh/site-functions/_ninja

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "Ninja\n\r\tApproximate Build Time: 0.1 SBU\n\r\tSpace: 11M\n\r\tVersion: 1.18.1"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall $*
}


main $*
