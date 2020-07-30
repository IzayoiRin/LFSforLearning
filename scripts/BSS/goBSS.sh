CHAROOT="${LFS}/chroot"


main(){
	cp -r */ $CHAROOT
	bash ./pre_basic_sys.sh
}


main
