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

# Build moab with no CGM 
cd $OWD
# moab install_dir already made by git
cd moab
autoreconf -fi
mkdir -p $OWD/bld_moab
cd $OWD/bld_moab
../moab/configure --enable-optimize --enable-shared --disable-debug --without-netcdf --enable-dagmc --with-hdf5=$OWD/hdf5 --prefix=$OWD/moab
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
# cd $OWD
# cp $FLUPRO/flutil/rfluka $FLUPRO/flutil/rfluka.orig
# Note: change the path to the patch
# patch $FLUPRO/flutil/rfluka $OWD/DAGMC/FluDAG/src/rfluka.patch 

# compile geant4
cd $OWD
mkdir -p $OWD/geant4/bld
cd $OWD/geant4/bld
cmake ../../geant4.10.00.p02/. -DCMAKE_INSTALL_PREFIX=$OWD/geant4
make
make install

# on redhat systems geant installs to a lib64 rather than lib
# copy rather than link to avoid downstream linking issues
if [ ! -d "$OWD/geant4/lib" ] ; then
    cp -r $OWD/geant4/lib64 $OWD/geant4/lib 
fi
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OWD/geant4/lib

# Mke everything in DAGMC
cd $OWD/DAGMC
mkdir bld
cd bld
cmake ../. -DMOAB_DIR=$OWD/moab/lib -DBUILD_FLUKA=ON -DFLUKA_DIR=$FLUPRO -DBUILD_GEANT4=ON -DGEANT4_DIR=$OWD/geant4/ -DCMAKE_INSTALL_PREFIX=$OWD/DAGMC
make 
make install
 
# Wrap up the results for downloading
cd $OWD
tar -pczf results.tar.gz moab hdf5 geant4 FLUKA/flutil/rfluka* DAGMC
exit $?
