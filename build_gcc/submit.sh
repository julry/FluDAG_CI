
if [ -z $1 ]
then
   echo "Error: No run-spec specified"
   exit 1
fi

path=`pwd`
echo "
method    = scp
scp_file  = $path/build_gcc482.sh
recursive = true
">$path/build_gcc482.sh.scp

echo "
method    = scp
scp_file  = $path/gcc-4.8.2-w-gmp-fix.tar.bz2
recursive = true
">$path/gcc-4.8.2.tar.bz2.scp

nmi_submit $1
