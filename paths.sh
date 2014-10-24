#!/bin/sh
set -x

OWD=$PWD
export LD_LIBRARY_PATH=$OWD/anaconda/lib:$OWD/geant4/lib:$OWD/DAGMC/lib
export PATH=$OWD/anaconda/bin:$OWD/anaconda/usr/local/bin:$PATH
# on Debian these dirs will exist and are needed
LAPACK='lapack-3.5.0'
F2C='libf2c'
if [ -d $F2C ] && [ -d $LAPACK ]  ; then
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OWD/$F2C:$OWD/$LAPACK
fi

