# !bin/bash

LOG_PREFIX="/sources/.logs/"
LOGS_NAME="XML-ParserInstallLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


iinstall(){
    echo "Prepare XML::Parser ... ..." 
    perl Makefile.PL 1>/dev/null 2>$LOGS
    
    echo "Making ... ..."
    make  1>/dev/null 2>>$LOGS

    if [ "${1}" == "--test" ];then
        echo "Expect Testing ... ..."
        make test 1> /dev/null 2>>$LOGS
    fi

    echo "Make-installing ... ..."
    make install 1> /dev/null 2>> $LOGS

    echo "Cleaning Temps ... ..."
    dir=`pwd`;cd ../
    echo "remove ${dir}"
    rm -rf $dir
    pwd
}


main(){
    echo -e "XML::Parser\n\r\tApproximate Build Time: <0.1 SBU\n\r\tSpace: 2.4M\n\r\tVersion: 2.46"
    echo ">>>>> Begin to COMPILE >>>>>"
    iinstall
}


main
