#!/bin/sh

if [ -z $1 ]
then
   echo "Error: No run-spec specified"
   exit 1
fi

path=`pwd`
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

nmi_submit $1
