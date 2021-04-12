#!/bin/bash


# Note: Needed to install the following.
# NetCDF_INCLUDE_DIRS=${TACC_NETCDF_INC} make nemsio sp w3emc sigio

if [[ $(uname -s) == Darwin ]]; then
  readonly UFS_MODEL_DIR=$(cd "$(dirname "$(greadlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
else
  readonly UFS_MODEL_DIR=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
fi





export CMAKE_C_COMPILER=${CMAKE_C_COMPILER:-${CC:-mpicc}}
export CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER:-${CXX:-mpicxx}}
export CMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER:-${FC:-mpif90}}

module load esmf nems python3

export NETCDF=${NETCDF:-${NETCDF_ROOT:?"Please set NETCDF/NETCDF_ROOT environment variable"}}
export ESMFMKFILE=${ESMFMKFILE:?"Please set ESMFMKFILE environment variable"}

export MYNCEPLIBS=$HOME/opt/nceplibs
export WW3_COMP=stampede.intel
export CMAKE_PREFIX_PATH=$MYNCEPLIBS/bacio-2.4.1:$MYNCEPLIBS/nemsio-2.5.2:$MYNCEPLIBS/w3nco-2.4.1:$MYNCEPLIBS/sp-2.3.3:$MYNCEPLIBS/w3emc-2.7.3:$MYNCEPLIBS/sigio-2.3.2


BUILD_DIR=${BUILD_DIR:-${UFS_MODEL_DIR}/build}
ADCIRC_BUILD_DIR=${ADCIRC_BUILD_DIR:-${UFS_MODEL_DIR}/adcirc-cg/build}


mkdir -p ${BUILD_DIR}
mkdir -p ${ADCIRC_BUILD_DIR}


[[ -n "${CCPP_SUITES:-""}" ]] && CMAKE_FLAGS+=" -DCCPP_SUITES=${CCPP_SUITES}"
CMAKE_FLAGS+=" -DNETCDF_DIR=${NETCDF}"

cd ${ADCIRC_BUILD_DIR}
cmake .. -DCMAKE_C_COMPILER=icc -DCMAKE_CXX_COMPILER=icpc -DCMAKE_Fortran_COMPILER=ifort -DENABLE_OUTPUT_NETCDF=ON -DCMAKE_Fortran_FLAGS_RELEASE="-O3 -xHOST" -DCMAKE_C_FLAGS_RELEASE="-O3 -xHOST" -DCMAKE_CXX_FLAGS_RELEASE="-O3 -xHOST" -DNETCDFHOME=$TACC_NETCDF_DIR -DBUILD_LIBADCIRC_STATIC=ON
make

cd ${BUILD_DIR}
cmake ${UFS_MODEL_DIR} ${CMAKE_FLAGS}
make -j ${BUILD_JOBS:-4} VERBOSE=${BUILD_VERBOSE:-}
