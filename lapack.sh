#!/bin/sh
# build_lapack.sh
#
# Build lapack and dependencies for the Debian platform
#
set -x
set -e
OWD=`pwd`
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Build lapack and its dependencies for Debian linux
export LAPACK='lapack-3.5.0'
export F2C='libf2c'
tar zxvf libf2c.tgz
# Pre-modified files for dynamic lib
cp $OWD/lapack_files/Makefile.libf2c $OWD/${F2C}/Makefile
cp $OWD/${F2C}/main.c $OWD/${F2C}/main.c.orig
cp $OWD/lapack_files/f2c.main.c $OWD/${F2C}/main.c
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
cp $OWD/lapack_files/lapack.make.inc make.inc
# store original makefiles - don't need to do
cp ./SRC/Makefile ./SRC/Makefile.orig
cp ./BLAS/SRC/Makefile ./BLAS/SRC/Makefile.orig
# copy in modified makefiles
cp $OWD/lapack_files/Makefile.lapack-3.5.0.SRC SRC/Makefile
cp $OWD/lapack_files/Makefile.lapack-3.5.0.BLAS.SRC BLAS/SRC/Makefile

LAPACK_LIB=$OWD/${LAPACK}
make blaslib LAPACK_LIBDIR=$LAPACK_LIB
make lapacklib LAPACK_LIBDIR=$LAPACK_LIB

cd $OWD
export LD_LIBRARY_PATH=$OWD/${LAPACK}

