
if [ -z $1 ]
then
   echo "Error: No run-spec specified"
   exit 1
fi

path=`pwd`
echo "
method    = scp
scp_file  = $path/build.sh
recursive = true
">$path/fludag.scp

nmi_submit $1
