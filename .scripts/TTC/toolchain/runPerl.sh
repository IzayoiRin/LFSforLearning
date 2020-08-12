# !bin/bash

CONFIGURE_FILE="Configure"
LOG_PREFIX="${LFS}/sources/.logs/"
LOGS_NAME="PerlRuningtimeLogs.log"
LOGS="${LOG_PREFIX}${LOGS_NAME}"


icompile(){
	conf="./${CONFIGURE_FILE}"
	if [ ! -f $conf ];then
		echo "Can't find $conf"
		return 1
	fi
	echo "Configuring ... ..."
	sh $conf \
	-des \
	-Dprefix=/tools \
	-Dlibs=-lm \
	-Uloclibpth \
	-Ulocincpth \
	1> /dev/null 2> $LOGS

	echo "Making ... ..."
	# compile package 
	make 1> /dev/null 2>> $LOGS

	echo "Make-installing ... ..."
	# install compiled package 
	cp -v perl cpan/podlators/scripts/pod2man /tools/bin
	mkdir -p /tools/lib/perl5/5.30.1
	echo "copy: lib/* --> /tools/lib/perl5/5.30.1"
	cp -R lib/* /tools/lib/perl5/5.30.1

	echo "Cleaning Temps ... ..."
	dir=`pwd`;cd ../
	echo "remove ${dir}"
	rm -rf $dir
	pwd
}


main(){
	echo -e "Perl\n\r\tApproximate Build Time: 1.5 SBU\n\r\tSpace: 275M\n\r\tVersion: 5.30.1"
	echo ">>>>> Begin to COMPILE >>>>>"
	icompile 
}


main 
