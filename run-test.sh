# set -e
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

exit $?
