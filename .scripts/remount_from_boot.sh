# !/bin/bash
export LC_ALL=C

DEV=/dev/sdb
mntRoot=$LFS
mntBoot=${LFS}"/boot"
swapon=/sbin/swapon
SWAP="swap"

mkMntdir()
{
    if [ ! -d $1 ]&&[ "$2" != "$SWAP" ];
    then
        echo "Can't find "$1
        echo "Make Dir "$1
        sudo mkdir -pv $1 2 >> mountLogs.log
    fi

    dev=$DEV$3
    if [ "$2" == "$SWAP" ];
    then
        sudo $1 -v $dev 2>> mountLogs.log
        echo "$2 >>> $dev [$2] MOUNTED"
    else
        sudo mount -v -t $2 $DEV$3 $1 2>> mountLogs.log
        echo "$1 >>> $dev [$2] MOUNTED"
    fi
}

main()
{
    echo -e "MountPath\nroot: "${mntRoot}"\nboot: "${mntBoot}
    
    echo "Root Linking:"
    mkMntdir $mntRoot "ext4" 3
    
    echo "Boot Linking:"
    mkMntdir $mntBoot "ext2" 1
    
    echo "Swap Linking:"
    mkMntdir $swapon $SWAP 2    
}
