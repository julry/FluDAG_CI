#!/bin/bash

if [ -z $1 ]
then
   echo "Error: No run-spec specified"
   exit 1
fi

path=$(pwd)

###############################################
# HANDLE SPECIAL DEBIAN SITUATION
###############################################
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
# We have this directory now gzipped so
# that can be read by Debian, just delete it.
rm -rf ./libf2c

# Make sure the tgz file just created,
# which is not in the repo, gets copied
echo \
"method  = scp
scp_file = $path/lapack_files/libf2c.tgz
">$path/lapack.scp
###############################################
# Done with HANDLE SPECIAL DEBIAN SITUATION
###############################################

# Needed in the case where the files are 
# a. not in the run-spec directory and
# b. not checked in
echo \
"method   = scp
scp_file  = $HOME/fluka/*
recursive = true
">$path/fluka.scp

nmi_submit $1
