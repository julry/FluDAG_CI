set -x
set -e

OWD=$PWD
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OWD/DAGMC/lib/
export LD_LIBRARY_PATH=$OWD/moab/lib/:$OWD/hdf5/lib:$OWD/geant4/lib/:$OWD/DAGMC/lib/

DAGMC/tests/fludag_unit_tests --gtest_list_tests  | python gen_test_list.py FLUDAG.
DAGMC/tests/fludag_unit_tests --gtest_list_tests  | python gen_test_list.py FLUDAG. > tasklist.nmi

DAGMC/tests/dagsolid_unit_tests --gtest_list_tests  | python gen_test_list.py DAGSOLID.
DAGMC/tests/dagsolid_unit_tests --gtest_list_tests  | python gen_test_list.py DAGSOLID. >> tasklist.nmi


exit $?

