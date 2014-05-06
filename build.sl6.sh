#!/bin/sh
# build.sl6.sh
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

gccdir="$PWD/gccSL6"

# This function fixes the non-portable libdir and
# dependency_lib settings in .la files created by our
# gcc build.  The paths are absolute, and cause libtool
# to fail when it reads said .la files.  This function
# will correct the paths in each .la file.
function fix_libtool {
   # Make an array of .la filenames
   la_files=($(find $gccdir/lib{,64} -name '*.la'))
   echo "\$la_files[@] is ${la_files[@]}"
   re_gccdir="${gccdir//\//\\/}"
   for la_file in "${la_files[@]}"; do
      echo "\$la_file is '$la_file'"
      # grab the variables, libdir particularly
      source $la_file
      echo "\$libdir is '$libdir'"
      # libdir_prefix is everything in the libdir variable up until
      # /lib is found.  For libdir /foo/bar/lib, it would be
      # /foo/bar.  For libdir /foo/bar/lib64, it would also be
      # /foo/bar.

      libdir_prefix="${libdir%%/lib*}"
      # regex-ready libdir_prefix (slashes escaped)
      re_libdir_prefix="${libdir_prefix//\//\\/}"
      # libdir_suffix is everything in the libdir variable after
      # libdir_prefix.  For libdir /foo/bar/lib, it would be
      # /lib.
      libdir_suffix="${libdir##${libdir_prefix}}"
      sed -i -r "s/${re_libdir_prefix}/${re_gccdir}/" "$la_file"
   done
}

# Run fix_libtool to fix the gcc .la files
fix_libtool

# Ensure all components build with local gcc
export LD_LIBRARY_PATH=${gccdir}/lib:${gccdir}/lib64
export PATH=${gccdir}/bin:$PATH

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
#mkdir $OWD/moab
cd ../moab
autoreconf -fi
cd ../bld_moab
../moab/configure --enable-optimize --enable-shared --disable-debug --without-netcdf --with-hdf5=$OWD/hdf5 --prefix=$OWD/moab
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

# Compile the fludag source and link it to the fludag and dagmc libraries
cd $OWD
mkdir -p $OWD/DAGMC/FluDAG/bld
cd $OWD/DAGMC/FluDAG/bld 
# This step runs cmake on a new, higher level CMakeLists.txt.
# Both the mainfludag and the tests will be built
# subdirectories will be made in the build directory for src and tests
cmake -DMOAB_HOME=$OWD/moab ..
make 


# compile geant4
cd $OWD
mkdir -p $OWD/geant4/bld
cd $OWD/geant4/bld
cmake ../../geant4.10.00.p01/. -DCMAKE_INSTALL_PREFIX=$OWD/geant4
make
make install
# on redhat systems geant installs to a lib64 rather than lib
# copy rather than link to avoid downstream linking issues
if [ ! -d "$OWD/geant4/lib" ] ; then
    cp -r $OWD/geant4/lib64 $OWD/geant4/lib 
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OWD/geant4/lib



# compile DagSolid
cd $OWD
mkdir -p $OWD/DAGMC/Geant4/dagsolid/bld
cd $OWD/DAGMC/Geant4/dagsolid/bld
# This step runs cmake on a new, higher level CMakeLists.txt.
# Both the mainfludag and the tests will be built
# subdirectories will be made in the build directory for src and tests
cmake ../. -DMOAB_DIR=$OWD/moab -DGEANT_DIR=$OWD/geant4 -DDAGSOLID_DIR=$OWD/DAGMC/Geant4/dagsolid
make 
make install
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OWD/DAGMC/Geant4/dagsolid/lib



# Wrap up the results for downloading
cd $OWD
tar -pczf results.tar.gz moab hdf5 geant4 FLUKA/flutil/rfluka* DAGMC/FluDAG/bld DAGMC/Geant4/dagsolid/
exit $?
