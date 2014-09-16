set -x
set -e

OWD=$PWD

gccdir="$PWD/gccSL6"
source ./general_exports.sh
# Ensure all components build with local gcc
# export LD_LIBRARY_PATH=${gccdir}/lib:${gccdir}/lib64
# export PATH=${gccdir}/bin:$PATH
source $OWD/geant4/bld/geant4make.sh

cd DAGMC/FluDAG/bld/tests
./fludag_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/FLUDAG.//g'`

cd $OWD/DAGMC/Geant4/dagsolid/bld/test
./dagsolid_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/DAGSOLID.//g'`


exit $?
