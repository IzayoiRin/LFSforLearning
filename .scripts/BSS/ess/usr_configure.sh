SOURCES="/sources/"
SETUP_ENV="/chroot/"
RUNSH="${SETUP_ENV}basicsys"
ESS_FILES="${SETUP_ENV}ess"

disk="sdb"
devices="${disk}1 ${disk}2 ${disk}3"
# /sys/class/video4linux/video0
dup_devices=""
version="9.1"
host_name="iLFS"


network_dev(){
	echo "Creating Custom Udev Rules ... ..."
	bash /lib/udev/init-net-rules.sh
	cat /etc/udev/rules.d/70-persistent-net.rules | grep -o '^[^#].*'
}


cd_rom(){
	for i in $devices;
	do
		udevadm test_rom /sys/block/${i} >test 2>&1
		echo $i
		cat test_rom | grep '.*_id' | grep '.*ID_\(SERIAL\|PATH\)'
	done
	rm test_rom

	# alter mode: by-id or by-path
	# sed -i -e 's/"write_cd_rules"/"write_cd_rules mode"/' \
	# /etc/udev/rules.d/83-cdrom-symlinks.rules
}


duplicate_devices(){
	for i in $dup_devices;
	do
		udevadm info -a -p ${i}
	done
}


sys_configure(){
	echo "Generic network configuring ... ..."
	cp -v ${ESS_FILES}/ifconfig.eth0 /etc/sysconfig/
	cp -v ${ESS_FILES}/resolv.conf /etc/
	echo ${host_name} > /etc/hostname
	cp -v ${ESS_FILES}/hosts /etc/
	echo "Sysinit"
	cp -v ${ESS_FILES}/inittab /etc/
	echo "Defualt sys configuering ... ..."
	cp -v ${ESS_FILES}/rc.site /etc/sysconfig/
	echo "Clock"
	cp -v ${ESS_FILES}/clock /etc/sysconfig/
	echo "Console"
	cp -v ${ESS_FILES}/console /etc/sysconfig/
	echo "Bash"
	cp -v ${ESS_FILES}/profile /etc/
	cp -v ${ESS_FILES}/shells /etc/
	cp -v ${ESS_FILES}/.bashrc /root/
	echo "Inputrc"
	cp -v ${ESS_FILES}/inputrc /etc/
}


boot_configure(){
	cp -v ${ESS_FILES}/fstab /etc/
	# cd $SOURCES
	# bash ${RUNSH}/manage.sh linux-5.5.3.tar.xz Linux
	grub-install /dev/${disk}
	cp -v ${ESS_FILES}/grub.cfg /boot/grub/
}


infos(){
	echo ${verson} > /etc/lfs-release
	cp ${ESS_FILES}/lsb-release /etc/
	cp ${ESS_FILES}/os-release /etc/


main(){
	cd $SOURCES
	# bash ${RUNSH}/manage.sh lfs-bootscripts-20191031.tar.xz LFS-bootscripts
	cd /
	network_dev
	cd_rom
	duplicate_devices
	sys_configure
	boot_configure
	infos
}

main
