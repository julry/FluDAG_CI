#!/bin/sh

if [ -z $1 ]
then
   echo "Error: No run-spec specified"
   exit 1
fi

path=`pwd`

# Debian platform has no unzip
# so unzip and tar up here
wget http://www.netlib.org/f2c/libf2c.zip
mkdir libf2c
cd libf2c
unzip ../libf2c.zip
cd ..
tar zcf libf2c.tgz libf2c
mv libf2c.tgz lapack_files
mv libf2c.zip lapack_files
rm -rf ./libf2c

echo \
"method  = scp
scp_file = $path/*.sh
">$path/scripts.scp

echo \
"method   = scp
scp_file  = $HOME/fluka/*
recursive = true
">$path/fluka.scp

echo \
"method   = scp
scp_file  = $path/gen_test_list.py
recursive = true
">$path/gen_test_list.py.scp
 
echo \
"method   = scp
scp_file  = $path/lapack_files/*
">$path/lapack.scp

nmi_submit $1
