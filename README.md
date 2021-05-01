#NEMSlite

##Initiate by:
git clone <NEMSlite url>
git submodule init
git submodule update

##Or:
git clone --recurse-submodules <NEMSlite url>

##module versions
Be sure each module is the correct branch by going into each submmodule subdirectory:

##adcirc-cg
cd adcirc-cg
git checkout ND_v55_NEMS

to build adcirc by itself with cmake:
mkdir build
cd build

cmake .. -DCMAKE_C_COMPILER=icc -DCMAKE_CXX_COMPILER=icpc -DCMAKE_Fortran_COMPILER=ifort -DENABLE_OUTPUT_NETCDF=ON -DCMAKE_Fortran_FLAGS_RELEASE="-O3 -xHOST" -DCMAKE_C_FLAGS_RELEASE="-O3 -xHOST" -DCMAKE_CXX_FLAGS_RELEASE="-O3 -xHOST" -DNETCDFHOME=$TACC_NETCDF_DIR -DBUILD_ADCPREP=ON -DBUILD_PADCIRC=ON -DBUILD_PADCSWAN=OFF -DBUILD_LIBADCIRC_STATIC=ON

##WW3
cd WW3
git checkout develop (main branch should be OK as well)

##ATMESH
cd ATMESH
git checkout new-cmake-build-system

#delete submodule
git submodule deinit -f -- submodulename
rm -rf .git/modules/submodulename
git rm -f submodulename
