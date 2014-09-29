set -x
set -e

OWD=$PWD

# export LD_LIBRARY_PATH=$OWD/moab/lib/:$OWD/hdf5/lib:$OWD/geant4/lib/:$OWD/DAGMC/lib/
# export LD_LIBRARY_PATH=$OWD/anaconda/lib/:$OWD/geant4/lib/
export LD_LIBRARY_PATH=$OWD/anaconda/lib/:$OWD/geant4/lib/:$OWD/DAGMC/lib
source $OWD/geant4/bld/geant4make.sh

cd DAGMC/tests
./fludag_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/FLUDAG.//g'`
./dagsolid_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/DAGSOLID.//g'`

# Pyne section
PATH=`pwd`/anaconda/bin:$PATH

export DYLD_FALLBACK_LIBRARY_PATH=`pwd`/anaconda/lib:`pwd`/anaconda/lib/python2.7/site-packages/itaps:$DYLD_FALLBACK_LIBRARY_PATH
export DYLD_LIBRARY_PATH=`pwd`/anaconda/lib:`pwd`/anaconda/lib/python2.7/site-packages/itaps:$DYLD_LIBRARY_PATH

`pwd`/anaconda/bin/nosetests -w ./pyne/tests

exit $?
