set -x
set -e

OWD=`pwd`

export LD_LIBRARY_PATH=$OWD/anaconda/lib/:$OWD/geant4/lib/:$OWD/DAGMC/lib
source $OWD/geant4/bld/geant4make.sh

cd $OWD/DAGMC/tests
./fludag_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/FLUDAG.//g'`
./dagsolid_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/DAGSOLID.//g'`

# Pyne section
export PATH=$OWD/anaconda/bin:$PATH

exit $?
