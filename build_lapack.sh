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

 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Build lapack for Debian linux
export LAPACK='lapack-3.5.0'
cd $OWD/${LAPACK}
# wget http://www.netlib.org/lapack-dev/lapack--3.0--patch--10042002.tgz
# tar zxvf lapack--3.0--patch--10042002.tgz
mv INSTALL/make.inc.LINUX make.inc
make install blaslib lib
mv lapack_LINUX.a liblapack.a
mv blas_LINUX.a librefblas.a
cd ..
export LD_LIBRARY_PATH=$OWD/${LAPACK}/lib:$LD_LIBRARY_PATH

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
chmod +x Miniconda-3.0.5-Linux-x86_64.sh
./Miniconda-3.0.5-Linux-x86_64.sh -b -p `pwd`/anaconda

export LD_LIBRARY_PATH=`pwd`/anaconda/lib:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=`pwd`/anaconda/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=`pwd`/anaconda/include:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=`pwd`/anaconda/lib:$LIBRARY_PATH
export HDF5_ROOT=`pwd`/anaconda

cdir=`pwd`/anaconda
export PATH=`pwd`/anaconda/bin:`pwd`/anaconda/usr/local/bin:$PATH
conda install conda-build jinja2 nose setuptools pytables hdf5 scipy cython cmake numpy
# Don't do if not linux
conda install patchelf

# modified dagmcci
cd moab
autoreconf -fi
./configure --prefix=$OWD/anaconda --enable-optimize --enable-shared --disable-debug --without-netcdf --enable-dagmc --with-hdf5=$OWD/anaconda
make
make install 

# make PyTAPs
cd ..
cd PyTAPS-1.4
python setup.py --iMesh-path=$OWD/anaconda install --prefix=$OWD/anaconda 

# make PyNE
cd ..
cd pyne
python setup.py install --prefix=$OWD/anaconda --hdf5=$OWD/anaconda -- -DMOAB_INCLUDE_DIR=$OWD/anaconda/include -DMOAB_LIBRARY=$OWD/anaconda/lib
cd scripts
env
nuc_data_make

# With the conda build, all libraries are in anaconda/lib
export LD_LIBRARY_PATH=$OWD/anaconda/lib

# Do not need to make the libflukahp.a library, but do need the environment vars
export FLUPRO=$OWD/FLUKA
export FLUFOR=gfortran

# Patch rfluka script so that it allows for longer filenames
cd $OWD
cp $FLUPRO/flutil/rfluka $FLUPRO/flutil/rfluka.orig
patch $FLUPRO/flutil/rfluka $OWD/DAGMC/fluka/rfluka.patch 

# compile geant4 -- Takes a lot of time!
mkdir -p $OWD/geant4/bld
cd $OWD/geant4/bld
cmake ../../geant4.10.00.p02/. -DCMAKE_INSTALL_PREFIX=$OWD/geant4
make -j 16
make install

# on redhat systems geant installs to a lib64 rather than lib
# copy rather than link to avoid downstream linking issues
if [ ! -d "$OWD/geant4/lib" ] ; then
    cp -r $OWD/geant4/lib64 $OWD/geant4/lib 
fi
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OWD/geant4/lib

# Make everything in DAGMC
mkdir -p $OWD/DAGMC/bld
cd $OWD/DAGMC/bld
cmake ../. -DMOAB_DIR=$OWD/anaconda/lib -DBUILD_FLUKA=ON -DFLUKA_DIR=$FLUPRO -DBUILD_GEANT4=ON -DGEANT4_DIR=$OWD/geant4/ -DCMAKE_INSTALL_PREFIX=$OWD/DAGMC
make 
make install
 
# Wrap up the results for downloading
cd $OWD
tar -pczf results.tar.gz anaconda geant4 FLUKA/flutil/rfluka* DAGMC ${LAPACK}
exit $?
