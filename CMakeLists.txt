cmake_minimum_required(VERSION 3.15)

foreach(env_var IN ITEMS CMAKE_C_COMPILER CMAKE_CXX_COMPILER CMAKE_Fortran_COMPILER)
  if(NOT DEFINED ENV{${env_var}})
    message(FATAL_ERROR "${env_var} is not defined")
  endif()
endforeach()

set(CMAKE_C_COMPILER $ENV{CMAKE_C_COMPILER})
set(CMAKE_CXX_COMPILER $ENV{CMAKE_CXX_COMPILER})
set(CMAKE_Fortran_COMPILER $ENV{CMAKE_Fortran_COMPILER})
set(CMAKE_Platform $ENV{CMAKE_Platform})
set(CMAKE_VERBOSE_MAKEFILE ON)

project(ufs
        VERSION 1.0
        LANGUAGES C CXX Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMakeModules/Modules)

find_package(MPI REQUIRED)
find_package(NetCDF REQUIRED C Fortran)
find_package(MPI REQUIRED)
find_package(ESMF MODULE REQUIRED)

find_package(bacio REQUIRED)
find_package(nemsio REQUIRED)
find_package(sp REQUIRED)
find_package(w3emc REQUIRED)
find_package(w3nco REQUIRED)

# Configure Python
find_package(Python 3 REQUIRED COMPONENTS Interpreter)
message("Found Python: ${Python_EXECUTABLE}")

add_subdirectory (WW3)
#add_subdirectory (adcirc-cg)
add_subdirectory (src)
