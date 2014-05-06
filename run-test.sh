set -x
set -e

gccdir="$PWD/gccSL6"
# Ensure all components build with local gcc
export LD_LIBRARY_PATH=${gccdir}/lib:${gccdir}/lib64
export PATH=${gccdir}/bin:$PATH

cd DAGMC/FluDAG/bld/tests
./fludag_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/FLUDAG.//g'`

cd ../../../..
cd DAGMC/Geant4/dagsolid/bld/tests
./dagsolid_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/DAGSOLID.//g'`


exit $?
