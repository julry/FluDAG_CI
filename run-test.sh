set -x
set -e

OWD=$PWD

# gccdir="$PWD/gccSL6"
# source ./general_exports.sh
# Ensure all components build with local gcc
# export LD_LIBRARY_PATH=${gccdir}/lib:${gccdir}/lib64
# export PATH=${gccdir}/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OWD/DAGMC/lib/
source $OWD/geant4/bld/geant4make.sh

cd DAGMC/tests
./fludag_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/FLUDAG.//g'`
./dagsolid_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/DAGSOLID.//g'`


exit $?
