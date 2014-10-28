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

# Add Tally unit tests
DAGMC/tests/test_KDEKernel --gtest_list_tests | python gen_test_list.py KDEKernel.
DAGMC/tests/test_KDEKernel --gtest_list_tests | python gen_test_list.py KDEKernel. >> tasklist.nmi

DAGMC/tests/test_KDENeighborhood --gtest_list_tests | python gen_test_list.py KDENeighborhood.
DAGMC/tests/test_KDENeighborhood --gtest_list_tests | python gen_test_list.py KDENeighborhood. >> tasklist.nmi

DAGMC/tests/test_PolynomialKernel --gtest_list_tests | python gen_test_list.py PolynomialKernel.
DAGMC/tests/test_PolynomialKernel --gtest_list_tests | python gen_test_list.py PolynomialKernel. >> tasklist.nmi

DAGMC/tests/test_Quadrature --gtest_list_tests | python gen_test_list.py Quadrature.
DAGMC/tests/test_Quadrature --gtest_list_tests | python gen_test_list.py Quadrature. >> tasklist.nmi

DAGMC/tests/test_Tally --gtest_list_tests | python gen_test_list.py Tally.
DAGMC/tests/test_Tally --gtest_list_tests | python gen_test_list.py Tally. >> tasklist.nmi

DAGMC/tests/test_TallyEvent --gtest_list_tests | python gen_test_list.py TallyEvent.
DAGMC/tests/test_TallyEvent --gtest_list_tests | python gen_test_list.py TallyEvent. >> tasklist.nmi

DAGMC/tests/test_TallyData --gtest_list_tests | python gen_test_list.py TallyData.
DAGMC/tests/test_TallyData --gtest_list_tests | python gen_test_list.py TallyData. >> tasklist.nmi

DAGMC/tests/test_CellTally --gtest_list_tests | python gen_test_list.py CellTally.
DAGMC/tests/test_CellTally --gtest_list_tests | python gen_test_list.py CellTally. >> tasklist.nmi

DAGMC/tests/test_KDEMeshTally --gtest_list_tests | python gen_test_list.py KDEMeshTally.
DAGMC/tests/test_KDEMeshTally --gtest_list_tests | python gen_test_list.py KDEMeshTally. >> tasklist.nmi

exit $?

