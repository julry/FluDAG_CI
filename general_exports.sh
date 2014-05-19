#!/bin/sh
# general_exports.sh
# Ensure all components build with local gcc
export LD_LIBRARY_PATH=${gccdir}/lib:${gccdir}/lib64
export PATH=${gccdir}/bin:$PATH
