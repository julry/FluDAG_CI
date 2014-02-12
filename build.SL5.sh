#!/bin/sh
#
# We don't proceed unless the preceding step succeeded, and
# we return the success or failure of the sequence.
#
# This version builds a moab stack with no cgm
#
set -x
set -e
echo "Building with local gcc 4.8.2"

OWD=`pwd`
DIR=`pwd`
# Out of source build for hdf5.  
mkdir `pwd`/bld_hdf5
cd bld_hdf5
../hdf5-1.8.11/configure --prefix=`pwd`/../install
make
make install
cd ..
DIR=`pwd`

# Build moab with no CGM; save the build directory
mkdir `pwd`/bld_moab
cd bld_moab
../moab-4.6.2/configure --enable-optimize --enable-shared --disable-debug --without-netcdf --with-hdf5=`pwd`/../install --prefix=`pwd`/../install
make
make install 
cd ..
DIR=`pwd`

# Copy rfluka script that allows for longer filenames
cd ./FLUKA/flutil
cp rfluka rfluka.orig
cd ../..
cp ./DAGMC/FluDAG/src/rfluka FLUKA/flutil
DIR=`pwd`

# The build failed when the following two lines were at the top of this script
export LD_LIBRARY_PATH=`pwd`/gccSL5/lib:`pwd`/gccSL5/lib64:$LD_LIBRARY_PATH
export PATH=`pwd`/gccSL5/bin:$PATH

# Do not need to make the libflukahp.a library, but do need the environment vars
export FLUPRO=`pwd`/FLUKA
export FLUFOR=gfortran
DIR=`pwd`
mkdir -p ./DAGMC/FluDAG/bld
cd ./DAGMC/FluDAG/bld
cmake ../src -DMOAB_HOME=`pwd`/../../../install
make
# cd ../../..
# DIR=`pwd`

# Make the gtest libraries so they are ready for the test phase
cd $OWD/DAGMC/gtest
mkdir `pwd`/lib
cd lib
cmake ../gtest-1.7.0
make
DIR=`pwd`

# Configure and make the unit tests
cd $OWD/DAGMC/FluDAG/src/test
mkdir `pwd`/bld
cd bld
cmake \
-D DAGMC_FLUDAG_SOURCE=$OWD/DAGMC/FluDAG/src/ \
-D MOAB_HOME=$OWD/install   \
-D GTEST_HOME=$OWD/DAGMC/gtest \
..
make

# Wrap up the results for downloading
cd $OWD
# tar -czf results.tar.gz ./bld_hdf5 ./bld_moab ./install ./FLUKA/flutil/rfluka* ./DAGMC/FluDAG/bld ./DAGMC/gtest/lib ./DAGMC/FluDAG/src/test
tar -czf results.tar.gz ./install ./FLUKA/flutil/rfluka* ./DAGMC/FluDAG/bld ./DAGMC/gtest/lib ./DAGMC/FluDAG/src/test
exit $?
