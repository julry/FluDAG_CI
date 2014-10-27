set -e
set -x

OWD=`pwd`

source $OWD/geant4/bld/geant4make.sh
# source paths.sh sets these slightly differently
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OWD/anaconda/lib/:$OWD/geant4/lib/:$OWD/DAGMC/lib
# export PATH=$OWD/anaconda/bin:$PATH
source $OWD/paths.sh

cd $OWD/DAGMC/tests
./fludag_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/FLUDAG.//g'`
./dagsolid_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/DAGSOLID.//g'`
./uwuw_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/UWUW.//g'`
./test_KDEKernel  --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/KDEKernel.//g'`
./test_KDENeighborhood  --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/KDENeighborhood.//g'`
./test_Quadrature  --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/Quadrature.//g'`
./test_PolynomialKernel  --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/PolynomialKernel.//g'`
./test_Tally  --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/Tally.//g'`
./test_CellTally  --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/CellTally.//g'`
./test_TallyData  --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/TallyData.//g'`
./test_TallyEvent  --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/TallyEvent.//g'`
./test_KDEMeshTally  --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/KDEMeshTally.//g'`

exit $?
