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
# Build lapack and its dependencies for Debian linux
export LAPACK='lapack-3.5.0'
export F2C='libf2c'
tar zxvf libf2c.tgz
cp $OWD/Makefile.libf2c $OWD/${F2C}/Makefile
cp $OWD/${F2C}/main.c $OWD/${F2C}/main.c.orig
cp $OWD/f2c.main.c $OWD/${F2C}/main.c
cd $OWD/${F2C}
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Make f2c.h
make hadd
# Make static lib
make
# need dynamic lib for lapack dynamic libs
make libf2c.so
cd $OWD/${LAPACK}
export LD_RUN_PATH=$OWD/${F2C}:$OWD/${LAPACK}
export LIBRARY_PATH=$OWD/${F2C}:$OWD/${LAPACK}
export LD_LIBRARY_PATH=$OWD/${F2C}:$OWD/${LAPACK}
env

# Build lapack for Debian linux
# wget http://www.netlib.org/lapack-dev/lapack--3.0--patch--10042002.tgz
# tar zxvf lapack--3.0--patch--10042002.tgz
# Copy a version of cmake that adds -fPIC to CFLAGS
cp $OWD/lapack.make.inc make.inc
cp ./SRC/Makefile ./SRC/Makefile.orig
cp ./BLAS/SRC/Makefile ./BLAS/SRC/Makefile.orig
cp $OWD/Makefile.lapack-3.5.0.SRC SRC/Makefile
cp $OWD/Makefile.lapack-3.5.0.BLAS.SRC BLAS/SRC/Makefile

LAPACK_LIB=$OWD/${LAPACK}
make blaslib LAPACK_LIBDIR=$LAPACK_LIB
make lapacklib LAPACK_LIBDIR=$LAPACK_LIB

cd $OWD
export LD_LIBRARY_PATH=$OWD/${LAPACK}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
chmod +x Miniconda-3.7.0-Linux-x86_64.sh
./Miniconda-3.7.0-Linux-x86_64.sh -b -p $OWD/anaconda

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OWD/anaconda/lib
export C_INCLUDE_PATH=$OWD/anaconda/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=$OWD/anaconda/include:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=$LD_LIBRARY_PATH
export RUNPATH=$LD_LIBRARY_PATH
export LD_RUN_PATH=$LD_LIBRARY_PATH
export HDF5_ROOT=$OWD/anaconda
env

# cdir=`pwd`/anaconda
export PATH=`pwd`/anaconda/bin:`pwd`/anaconda/usr/local/bin:$PATH
conda install conda-build jinja2 nose setuptools pytables hdf5 scipy cython cmake numpy
conda install patchelf

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# modified dagmcci
cd moab
autoreconf -fi
./configure --prefix=$OWD/anaconda --enable-optimize --enable-shared --disable-debug --without-netcdf --enable-dagmc --with-hdf5=$OWD/anaconda
make
make install 

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# make PyTAPs
cd ..
cd PyTAPS-1.4
python setup.py --iMesh-path=$OWD/anaconda install --prefix=$OWD/anaconda 

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# make PyNE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cd ..
cd pyne
python setup.py install --prefix=$OWD/anaconda --hdf5=$OWD/anaconda -- -DMOAB_INCLUDE_DIR=$OWD/anaconda/include -DMOAB_LIBRARY=$OWD/anaconda/lib
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# With the conda build, all libraries are in anaconda/lib
# export LD_LIBRARY_PATH=$OWD/anaconda/lib

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
tar -pczf results.tar.gz anaconda geant4 FLUKA/flutil/rfluka* DAGMC ${LAPACK} ${F2C}
exit $?
