set -x
set -e

gccdir="$PWD/gccSL6"
# Ensure all components build with local gcc
export LD_LIBRARY_PATH=${gccdir}/lib:${gccdir}/lib64
export PATH=${gccdir}/bin:$PATH

DAGMC/FluDAG/bld/tests/fludag_unit_tests --gtest_list_tests  | python gen_test_list.py FLUDAG.
DAGMC/FluDAG/bld/tests/fludag_unit_tests --gtest_list_tests  | python gen_test_list.py FLUDAG. > tasklist.nmi

DAGMC/Geant4/dagsolid/bld/tests/dagsolid_unit_tests --gtest_list_tests  | python gen_test_list.py DAGSOLID.
DAGMC/Geant4/dagsolid/bld/tests/dagsolid_unit_tests --gtest_list_tests  | python gen_test_list.py DAGSOLID. >> tasklist.nmi


exit $?

