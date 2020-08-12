# !/bin/bash
# Simple script to list version numbers of critical development tools
export LC_ALL=C
# head -n1 get first line
# cut -d[simble] -f[range] cut text depend on [simble] then get [range]
bash --version | head -n1 | cut -d" " -f2-4
# [O]bash, version 4.4.20(1)-release
# readlink -f file get file link
MYSH=$(readlink -f /bin/sh)
echo "/bin/sh -> $MYSH"
# [O]/bin/sh -> /bin/bash
# grep -q: show nothing on console
# || means 'OR'
echo $MYSH | grep -q bash || echo "ERROR: /bin/sh does not point to bash"
# unset var: remove varible
unset MYSH
# GNU GCC ld sudo apt install binutils
echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-
# [O]Binutils: (GNU Binutils for Ubuntu) 2.30
# sudo apt install bison++
bison --version | head -n1
#[O]bison++ Version 1.21.9-1, adapted from GNU bison by coetmeur@icdc.fr
# [ -h /usr/bin/yacc ]: judge file whether soft-link
if [ -h /usr/bin/yacc ]; 
then
    echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
elif [ -x /usr/bin/yacc ];
then
    echo yacc is `/usr/bin/yacc --version | head -n1`
else
    echo "yacc not foud"
fi
# 2 means stderr; 1 means stdout; 0 means stdin
# n >& m repr merge n to output m
# n <& m repr merge n to input m
bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-
echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
diff --version | head -n1
find --version | head -n1
gawk --version | head -n1
if [ -h /usr/bin/awk ];
then
    echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
elif [ -x /usr/bin/awk ];
then
    echo awk is `/usr/bin/awk --version | head -n1`
else
        echo "awk not found"
fi
gcc --version | head -n1
g++ --version | head -n1
ldd --version | head -n1 | cut -d" " -f2- #glibc version
grep --version | head -n1
gzip --version | head -n1
cat /proc/version
m4 --version | head -n1
patch --version | head -n1
echo Perl `perl -V:version`
python3 --version
sed --version | head -n1
tar --version | head -n1
makeinfo --version | head -n1
xz --version | head -n1
echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
if [ -x dummy ]
then
        echo "g++ compilation OK";
else
        echo "g++ compilation failed";
fi
rm -f dummy.c dummy
