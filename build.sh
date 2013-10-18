#!/bin/sh
#
# We don't proceed unless the preceding step succeeded, and
# we return the success or failure of the sequence.
#
# This version builds a moab stack with no cgm
#
set -x
set -e

DIR=`pwd`

cd hdf5-1.8.11
./configure --prefix=`pwd`/../install
make
make install
cd ..
DIR=`pwd`

cd moab-4.6.2
./configure --enable-optimize --enable-shared --disable-debug --without-netcdf --with-hdf5=`pwd`/../install --prefix=`pwd`/../install
make
make install 
cd ..
DIR=`pwd`

cd FLUKA/flutil
cp rfluka rfluka.orig
cd ../..
cp DAGMC/FluDAG/src/rfluka FLUKA/flutil

DIR=`pwd`
mkdir -p DAGMC/FluDAG/bld
cd DAGMC/FluDAG/bld
cmake ../src -DMOAB_HOME=`pwd`/../../../moab-4.6.2
make
cd ../../..
DIR=`pwd`

tar -czf results.tar.gz ./install ./FLUKA/flutil/rfluka* ./DAGMC/FluDAG/bld
exit $?
