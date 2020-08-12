# !/bin/bansh
export LC_ALL=C

sourceRoot=$LFS/sources
wgetList="wget_list"

if [ ! -d $sourceRoot ]
then
    sudo mkdir -v $sourceRoot | chmod -v a+wt 2>> downloadLogs.log
fi

if [ -f $wgetList ];
then
    wget --input-file=$wgetList --continue --directory-prefix=$sourceRoot 2>> downloadLogs.log
fi
