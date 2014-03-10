#!/bin/sh
# build.SL6.sh
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
# ./env.sh

# Ensure all components build with local gcc
export LD_LIBRARY_PATH=$OWD/gccSL6/lib:$OWD/gccSL6/lib64
export PATH=$OWD/gccSL6/bin:$PATH


# Out of source build for hdf5.  
mkdir $OWD/bld_hdf5
cd bld_hdf5
# create install dir
mkdir $OWD/hdf5
../hdf5-1.8.11/configure --enable-shared --prefix=$OWD/hdf5
make
make install
# add to the shared lib path
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OWD/hdf5/lib
# dont need these, but may prove useful in future
export PATH=$PATH:$OWD/hdf5/bin
cd ..
# back in $OWD

# Build moab with no CGM 
mkdir $OWD/bld_moab
cd bld_moab
# make moab install dir
mkdir $OWD/moab
../moab-4.6.2/configure --enable-optimize --enable-shared --disable-debug --without-netcdf --with-hdf5=$OWD/hdf5 --prefix=$OWD/moab
export LD_LIBRARY_PATH=`pwd`/../gccSL6/lib:`pwd`/../gccSL6/lib64
make
make install 
# add to the shared lib path
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OWD/moab/lib
# dont need them but may be useful
export PATH=$PATH:$OWD/moab/bin
# cd ..

# Do not need to make the libflukahp.a library, but do need the environment vars
export FLUPRO=$OWD/FLUKA
export FLUFOR=gfortran

# Copy rfluka script that allows for longer filenames
cd $FLUPRO/flutil
cp rfluka rfluka.orig
cp $OWD/DAGMC/FluDAG/src/rfluka . 

# Compile the fludag source and link it to the fludag and dagmc libraries
cd $OWD
mkdir -p $OWD/DAGMC/FluDAG/bld
cd $OWD/DAGMC/FluDAG/bld 
cmake ../src -DMOAB_HOME=$OWD/moab -DFLUDAG_SOURCE=$OWD/DAGMC/FluDAG/src/
make

# Make the gtest libraries so they are ready for the test phase
# NOTE:  this should be part of the fludag build
cd $OWD/DAGMC/gtest
mkdir `pwd`/lib
cd lib
cmake ../gtest-1.7.0
make

# Configure and make the unit tests
cd $OWD/DAGMC/FluDAG/src/test
mkdir `pwd`/bld
cd bld
cmake -D DAGMC_FLUDAG_SOURCE=$OWD/DAGMC/FluDAG/src/ -D MOAB_HOME=$OWD/moab -D GTEST_HOME=$OWD/DAGMC/gtest ..
make

# Wrap up the results for downloading
cd $OWD
# tar -czf results.tar.gz ./bld_hdf5 ./bld_moab ./install ./FLUKA/flutil/rfluka* ./DAGMC/FluDAG/bld ./DAGMC/gtest/lib ./DAGMC/FluDAG/src/test
tar -pczf results.tar.gz moab hdf5 FLUKA/flutil/rfluka* DAGMC/FluDAG/bld DAGMC/gtest/lib DAGMC/FluDAG/src/test
exit $?
