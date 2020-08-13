sudo rm -rf $LFS/chroot
sudo umount -v $LFS/dev/pts
sudo umount -v $LFS/dev
sudo umount -v $LFS/run
sudo umount -v $LFS/proc
sudo umount -v $LFS/sys
sudo umount -v $LFS
sudo umount -v $LFS/usr
sudo umount -v $LFS/home
sudo umount -v $LFS

sudo shutdown -r now