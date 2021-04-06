# See https://github.com/NOAA-EMC/NCEPLIBS-nemsio/pull/22
#target_link_libraries(nemsio::nemsio INTERFACE w3emc::w3emc_d bacio::bacio_4)

###############################################################################
### NEMS Library
###############################################################################
list(APPEND _nems_srcs module_NEMS_UTILS.F90
                       module_MEDIATOR_methods.F90
                       module_MEDIATOR.F90
                       module_MEDIATOR_SpaceWeather.F90
                       module_EARTH_INTERNAL_STATE.F90
                       module_EARTH_GRID_COMP.F90
                       module_NEMS_INTERNAL_STATE.F90
                       module_NEMS_GRID_COMP.F90
                       module_NEMS_Rusage.F90
                       nems_c_rusage.c)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/ESMFVersionDefine_ESMF_NUOPC.h
               ${CMAKE_CURRENT_BINARY_DIR}/ESMFVersionDefine.h
               COPYONLY)
# until we remove "../ESMFVersionDefine.h" from ENS_Cpl/ENS_CplComp_ESMFMod_STUB.F90
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/ESMFVersionDefine_ESMF_NUOPC.h
               ${CMAKE_CURRENT_BINARY_DIR}/NEMS/ESMFVersionDefine.h
               COPYONLY)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/ESMFConvenienceMacros.h
               ${CMAKE_CURRENT_BINARY_DIR}/ESMFConvenienceMacros.h
               COPYONLY)

add_library(ufs ${_nems_srcs})
set_target_properties(ufs PROPERTIES Fortran_MODULE_DIRECTORY
                                     ${CMAKE_CURRENT_BINARY_DIR}/mod)
target_include_directories(ufs PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
target_include_directories(ufs INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/mod>
                                         $<INSTALL_INTERFACE:mod>)

list(APPEND _ufs_defs_private ESMF_VERSION_MAJOR=${ESMF_VERSION_MAJOR})

#if(WW3)
#  add_dependencies(ufs ww3_nems)
  list(APPEND _ufs_defs_private FRONT_WW3=WMESMFMD)
#  target_include_directories(ufs PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/WW3/model/mod)
#  list(APPEND _ufs_libs_public ${WW3_LIBS})
#endif()

#list(APPEND _ufs_libs_public esmf)

target_compile_definitions(ufs PRIVATE "${_ufs_defs_private}")
target_link_libraries(ufs PUBLIC esmf ww3_multi_esmf)

###############################################################################
### UFS executable
###############################################################################
add_executable(ufs_model MAIN_NEMS.F90)
add_dependencies(ufs_model ufs)

list(APPEND _ufs_model_defs_private ESMF_VERSION_MAJOR=${ESMF_VERSION_MAJOR})

set_target_properties(ufs_model PROPERTIES Fortran_MODULE_DIRECTORY
                                           ${CMAKE_CURRENT_BINARY_DIR}/mod)

target_include_directories(ufs_model PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

if(WW3)
  list(APPEND _ufs_model_defs_private FRONT_WW3=WMESMFMD)
  target_include_directories(ufs_model PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}../../WW3/model/mod)
endif()

target_compile_definitions(ufs_model PRIVATE "${_ufs_model_defs_private}")

if(NEMSdatm)
  target_link_libraries(ufs_model PUBLIC ufs w3nco::w3nco_d)
endif()

target_link_libraries(ufs_model PRIVATE esmf
                                        ufs
                                        NetCDF::NetCDF_Fortran
					w3nco::w3nco_d)
