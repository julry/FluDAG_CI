#!/bin/bash
set -x
set -e

# original working directory
OWD=`pwd`

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
######################################

# install deps
######################################
conda install nose pytables hdf5 scipy cython cmake numpy moab
######################################

# Install PyTAPS on Python 2 only
if [[ "$MINICONDA_PYVER" == "2" ]]; then
  conda install pytaps
fi

# build and install pyne conda package
######################################
conda_build pyne
######################################
# Don't need to install
# vers=$(cat pyne/meta.yaml | grep version)
# read -a versArray <<< $vers
# conda install --use-local pyne=${versArray[1]}

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
