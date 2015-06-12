#!/bin/bash
set -x
set -e

# original working directory
OWD=`pwd`

source lapack.sh

# Install conda - this runs the miniconda script
# installs a .condarc that's mostly about binstar - do I need?
# also runs update conda, installs jinja2, setuptools and binstar
# installs patchelf and conda-build
######################################
./bin/conda-inst.sh
######################################
# Sets up environment path vars identical to previous; 
# defines function conda_build(), which calls 
# conda build ... and makes the tar -uf happen
######################################
source conda_env.sh
# get glibc version, minorly apologetic for this.
# jcz note:  turns out this build is run on Debian7 and it apparently has an outdated glibc
export LDD_VER="$(ldd --version)"
export GLIBC_MAJOR_VERSION=$(python -c "print('''${LDD_VER}'''.splitlines()[0].split()[-1].split('.')[0])")
export GLIBC_MINOR_VERSION=$(python -c "print('''${LDD_VER}'''.splitlines()[0].split()[-1].split('.')[1])")
######################################

# install deps
######################################
conda install nose pytables hdf5 scipy cython cmake numpy moab
######################################

# Install PyTAPS on Python 2 only
if [[ "$MINICONDA_PYVER" == "2" ]]; then
  conda install pytaps
fi

# jcz note -- installing glibc prior to conda_build pyne
# on Debian 7 produced a segfault during the pyne build.
if [ "14" -gt "$GLIBC_MINOR_VERSION" ]; then
  conda install glibc
fi
#build and install pyne conda package
######################################
conda_build pyne
######################################

export FLUPRO=$OWD/FLUKA
export FLUFOR=gfortran

# Patch rfluka script so that it allows for longer filenames
cd $OWD
cp $FLUPRO/flutil/rfluka $FLUPRO/flutil/rfluka.orig
patch $FLUPRO/flutil/rfluka $OWD/DAGMC/fluka/rfluka.patch

# compile geant4 -- Takes a lot of time, use more cores
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
cmake ../. -DMOAB_DIR=$OWD/anaconda/lib -DBUILD_FLUKA=ON -DFLUKA_DIR=$FLUPRO -DBUILD_GEANT4=ON -DGEANT4_DIR=$OWD/geant4/ -DBUILD_TALLY=ON -DCMAKE_INSTALL_PREFIX=$OWD/DAGMC
make 
make install
 
cd $OWD
mv results.tar pyne-pkgs.tar
tar -pczf results.tar.gz pyne-pkgs.tar anaconda 
echo ""
echo "Results Listing"
echo "---------------"
tar -ztvf results.tar.gz
