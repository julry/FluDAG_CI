#!/bin/sh
# build.sh
#
# We don't proceed unless the preceding step succeeded, and
# we return the success or failure of the sequence.
#
# This version builds a moab stack with no cgm
#
set -x
set -e

# original working directory
OWD=`pwd`

# Out of source build for hdf5.  
mkdir $OWD/bld_hdf5
cd bld_hdf5
# create install dir
mkdir $OWD/hdf5
../hdf5-1.8.11/configure --enable-shared --prefix=$OWD/hdf5
make
make install
# set the shared lib path
export LD_LIBRARY_PATH=$OWD/hdf5/lib
# dont need these, but may prove useful in future
export PATH=$PATH:$OWD/hdf5/bin
cd ..

# Build moab with no CGM 
mkdir $OWD/bld_moab
cd bld_moab
# make moab install dir
mkdir $OWD/moab
../moab-4.6.2/configure --enable-optimize --enable-shared --disable-debug --without-netcdf --with-hdf5=$OWD/hdf5 --prefix=$OWD/moab
make
make install 
# add to the shared lib path
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OWD/moab/lib
# dont need them but may be useful
export PATH=$PATH:$OWD/moab/bin

# Do not need to make the libflukahp.a library, but do need the environment vars
export FLUPRO=$OWD/FLUKA
export FLUFOR=gfortran

# Patch rfluka script so that it allows for longer filenames
cd $OWD
cp $FLUPRO/flutil/rfluka $FLUPRO/flutil/rfluka.orig
patch $FLUPRO/flutil/rfluka $OWD/DAGMC/FluDAG/src/rfluka.patch 

# Configure and make the gtest libs and unit tests
# Make the gtest libraries so they are ready for the test phase
# NOTE:  this will  be part of the fludag build soon

# cd $OWD/DAGMC/gtest
# mkdir `pwd`/lib
# cd lib
# cmake ../gtest-1.7.0
# /.make

# Compile the fludag source and link it to the fludag and dagmc libraries
cd $OWD
mkdir -p $OWD/DAGMC/FluDAG/bld
cd $OWD/DAGMC/FluDAG/bld 
# This step runs cmake on a new, higher level CMakeLists.txt.
# Both the mainfludag and the tests will be built
# subdirectories will be made in the build directory for src and tests
cmake -DMOAB_HOME=$OWD/moab ..
make 

# Wrap up the results for downloading
cd $OWD
tar -pczf results.tar.gz moab hdf5 FLUKA/flutil/rfluka* DAGMC/FluDAG/bld 
exit $?
