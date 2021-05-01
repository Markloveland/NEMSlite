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
INCLUDE_DIR=${INCLUDE_DIR:-${UFS_MODEL_DIR}/include}
LIB_DIR=${LIB_DIR:-${UFS_MODEL_DIR}/lib}
ADCIRC_DIR=${ADCIRC_DIR:-${UFS_MODEL_DIR}/adcirc-cg}
WW3_DIR=${WW3_DIR:-${UFS_MODEL_DIR}/WW3}
ATMESH_DIR=${ATMESH_DIR:-${UFS_MODEL_DIR}/ATMESH}
ADC_CAP_DIR=${ADC_CAP_DIR:-${UFS_MODEL_DIR}/adc_cap}

mkdir -p ${BUILD_DIR}
mkdir -p ${INCLUDE_DIR} 
mkdir -p ${LIB_DIR}


mkdir -p ${BUILD_DIR}/adcirc-cg
mkdir -p ${BUILD_DIR}/WW3
mkdir -p ${BUILD_DIR}/ATMESH
mkdir -p ${BUILD_DIR}/adc_cap

mkdir -p ${INCLUDE_DIR}/adcirc-cg
mkdir -p ${INCLUDE_DIR}/WW3
mkdir -p ${INCLUDE_DIR}/ATMESH
mkdir -p ${INCLUDE_DIR}/adc_cap

mkdir -p ${LIB_DIR}/adcirc-cg
mkdir -p ${LIB_DIR}/WW3
mkdir -p ${LIB_DIR}/ATMESH
mkdir -p ${LIB_DIR}/adc_cap


[[ -n "${CCPP_SUITES:-""}" ]] && CMAKE_FLAGS+=" -DCCPP_SUITES=${CCPP_SUITES}"
CMAKE_FLAGS+=" -DNETCDF_DIR=${NETCDF}"

#Build adcirc static library
cd ${BUILD_DIR}/adcirc-cg
cmake ${ADCIRC_DIR} -DCMAKE_C_COMPILER=icc -DCMAKE_CXX_COMPILER=icpc -DCMAKE_Fortran_COMPILER=ifort -DENABLE_OUTPUT_NETCDF=ON -DCMAKE_Fortran_FLAGS_RELEASE="-O3 -xHOST" -DCMAKE_C_FLAGS_RELEASE="-O3 -xHOST" -DCMAKE_CXX_FLAGS_RELEASE="-O3 -xHOST" -DNETCDFHOME=$TACC_NETCDF_DIR -DBUILD_LIBADCIRC_STATIC=ON
make
#copy files to include and bin
cp *.a ${LIB_DIR}/adcirc-cg/.
cp CMakeFiles/mod/libadcirc_static/*.mod ${INCLUDE_DIR}/adcirc-cg/.


#build wavewatch 3 library
cd ${BUILD_DIR}/WW3
cmake ${WW3_DIR} -DCMAKE_C_COMPILER=icc -DCMAKE_CXX_COMPILER=icpc -DCMAKE_Fortran_COMPILER=ifort -DCMAKE_Fortran_FLAGS_RELEASE="-O3 -xHOST" -DCMAKE_C_FLAGS_RELEASE="-O3 -xHOST" -DCMAKE_CXX_FLAGS_RELEASE="-O3 -xHOST"
make
#cp lib/mod files
cp model/esmf/*.a ${LIB_DIR}/WW3/.
cp model/esmf/mod/*.mod ${INCLUDE_DIR}/WW3/.


#build atmesh library
cd ${BUILD_DIR}/ATMESH
cmake ${ATMESH_DIR} -DCMAKE_C_COMPILER=icc -DCMAKE_CXX_COMPILER=icpc -DCMAKE_Fortran_COMPILER=ifort -DCMAKE_Fortran_FLAGS_RELEASE="-O3 -xHOST" -DCMAKE_C_FLAGS_RELEASE="-O3 -xHOST" -DCMAKE_CXX_FLAGS_RELEASE="-O3 -xHOST"
make
#copy files to include and bin
cp *.a ${LIB_DIR}/ATMESH/.
cp *.mod ${INCLUDE_DIR}/ATMESH/.

#build adcirc cap
cd ${BUILD_DIR}/adc_cap
cmake ${ADC_CAP_DIR} -DCMAKE_C_COMPILER=icc -DCMAKE_CXX_COMPILER=icpc -DCMAKE_Fortran_COMPILER=ifort -DCMAKE_Fortran_FLAGS_RELEASE="-O3 -xHOST" -DCMAKE_C_FLAGS_RELEASE="-O3 -xHOST" -DCMAKE_CXX_FLAGS_RELEASE="-O3 -xHOST" -DADCIRC_DIR=${BUILD_DIR}/adcirc-cg/CMakeFiles/mod/libadcirc_static
make
#move lib and mod files
cp *.a ${LIB_DIR}/adc_cap/.
cp CMakeFiles/mod/*.mod ${INCLUDE_DIR}/adc_cap/. 


#cd ${BUILD_DIR}
#cmake ${UFS_MODEL_DIR} ${CMAKE_FLAGS}
#make -j ${BUILD_JOBS:-4} VERBOSE=${BUILD_VERBOSE:-}
