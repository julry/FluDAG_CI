set -x
set -e

source paths.sh

DAGMC/tests/fludag_unit_tests --gtest_list_tests  | python gen_test_list.py FLUDAG.
DAGMC/tests/fludag_unit_tests --gtest_list_tests  | python gen_test_list.py FLUDAG. > tasklist.nmi

DAGMC/tests/dagsolid_unit_tests --gtest_list_tests  | python gen_test_list.py DAGSOLID.
DAGMC/tests/dagsolid_unit_tests --gtest_list_tests  | python gen_test_list.py DAGSOLID. >> tasklist.nmi

# Add files uwuw_unit_tests
DAGMC/tests/uwuw_unit_tests --gtest_list_tests | python gen_test_list.py UWUW.
DAGMC/tests/uwuw_unit_tests --gtest_list_tests | python gen_test_list.py UWUW. >> tasklist.nmi

exit $?

