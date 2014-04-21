set -x
set -e
cd DAGMC/FluDAG/bld/tests
./fludag_unit_tests --gtest_filter=`echo ${_NMI_TASKNAME} | sed -e 's/__/\//g' | sed -e 's/FLUDAG.//g'`

exit $?
