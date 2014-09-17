set -x
set -e

OWD=$PWD

# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OWD/DAGMC/lib/
# export LD_LIBRARY_PATH=$OWD/DAGMC/lib/
export LD_LIBRARY_PATH=$OWD/moab/lib/:$OWD/hdf5/lib:$OWD/geant4/lib/:$OWD/DAGMC/lib/
source $OWD/geant4/bld/geant4make.sh

cd DAGMC/tests
./fludag_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/FLUDAG.//g'`
./dagsolid_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/DAGSOLID.//g'`


exit $?
