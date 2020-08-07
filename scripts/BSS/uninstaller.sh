main(){
	echo "! Remove Temp Toolchains."
	rm -rf /tools

	echo "! Remove unsuppressed statci libs."
	rm -vf /usr/lib/lib{bfd,opcodes}.a
	rm -vf /usr/lib/libbz2.a
	rm -vf /usr/lib/lib{com_err,e2p,ext2fs,ss}.a
	rm -vf /usr/lib/libltdl.a
	rm -vf /usr/lib/libfl.a
	rm -vf /usr/lib/libz.a

	echo "! Remove necessary files."
	find /usr/lib /usr/libexec -name \*.la -delete
}