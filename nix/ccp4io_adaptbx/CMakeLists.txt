cmake_minimum_required(VERSION 3.25)
project(ccp4io_adaptbx LANGUAGES C CXX)

if(POLICY CMP0167)
  cmake_policy(SET CMP0167 NEW)
endif()

include(GNUInstallDirs)
find_package(Python3 3.13 EXACT REQUIRED COMPONENTS Interpreter Development.Module)
find_package(Threads REQUIRED)

set(_boost_python_component "python${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR}")
set(_boost_numpy_component "numpy${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR}")
find_package(Boost 1.70 REQUIRED COMPONENTS
  ${_boost_python_component}
  ${_boost_numpy_component}
)

# Source locations of the vendored CCP4, MMDB and SSM trees plus the CCTBX
# repository (for boost_adaptbx / scitbx headers). Configure these from Nix.
set(CCP4IO_SOURCE_DIR "" CACHE PATH "Root of the ccp4io repository")
set(CCP4IO_ADAPTBX_SOURCE_DIR "" CACHE PATH "Root of the ccp4io_adaptbx repository")
set(CCTBX_SOURCE_DIR "" CACHE PATH "Root of the cctbx_project repository")

if(NOT CCP4IO_SOURCE_DIR OR NOT CCP4IO_ADAPTBX_SOURCE_DIR)
  message(FATAL_ERROR "CCP4IO_SOURCE_DIR and CCP4IO_ADAPTBX_SOURCE_DIR are required")
endif()

set(CMAKE_C_STANDARD 90)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Build the vendored ccp4io static library from the ccp4io tree, using the
# ccp4io_adaptbx printf wrappers so all printf/fprintf calls are redirected.
set(CCP4_CCP4_DIR "${CCP4IO_SOURCE_DIR}/libccp4/ccp4")
set(CCP4_FORTRAN_DIR "${CCP4IO_SOURCE_DIR}/libccp4/fortran")
set(CCP4_MMDB_DIR "${CCP4IO_SOURCE_DIR}/mmdb")
set(CCP4_SSM_DIR "${CCP4IO_SOURCE_DIR}/ssm")
set(ADAPBX_DIR "${CCP4IO_ADAPTBX_SOURCE_DIR}")

# Files that live in the fortran tree but are compiled as C (they were
# copied/adapted there upstream). Their sources use ccp4io_* printf wrappers.
set(CCP4_FORTRAN_C_FILES
  ${CCP4_FORTRAN_DIR}/ccp4_diskio_f.c
  ${CCP4_FORTRAN_DIR}/ccp4_general_f.c
  ${CCP4_FORTRAN_DIR}/ccp4_parser_f.c
  ${CCP4_FORTRAN_DIR}/ccp4_unitcell_f.c
  ${CCP4_FORTRAN_DIR}/cmaplib_f.c
  ${CCP4_FORTRAN_DIR}/cmtzlib_f.c
  ${CCP4_FORTRAN_DIR}/csymlib_f.c
  ${CCP4_FORTRAN_DIR}/library_f.c
)

set(CCP4_SINGLE_C_FILES
  ${CCP4_CCP4_DIR}/ccp4_general.c
  ${CCP4_CCP4_DIR}/ccp4_program.c
)

set(CCP4_C_FILES
  ${CCP4_CCP4_DIR}/library_err.c
  ${CCP4_CCP4_DIR}/library_file.c
  ${CCP4_CCP4_DIR}/library_utils.c
  ${CCP4_CCP4_DIR}/ccp4_array.c
  ${CCP4_CCP4_DIR}/ccp4_parser.c
  ${CCP4_CCP4_DIR}/ccp4_unitcell.c
  ${CCP4_CCP4_DIR}/cvecmat.c
  ${CCP4_CCP4_DIR}/cmtzlib.c
  ${CCP4_CCP4_DIR}/cmap_accessor.c
  ${CCP4_CCP4_DIR}/cmap_close.c
  ${CCP4_CCP4_DIR}/cmap_data.c
  ${CCP4_CCP4_DIR}/cmap_header.c
  ${CCP4_CCP4_DIR}/cmap_labels.c
  ${CCP4_CCP4_DIR}/cmap_open.c
  ${CCP4_CCP4_DIR}/cmap_skew.c
  ${CCP4_CCP4_DIR}/cmap_stats.c
  ${CCP4_CCP4_DIR}/cmap_symop.c
  ${CCP4_CCP4_DIR}/csymlib.c
  ${CCP4_CCP4_DIR}/ccp4_general.c
  ${CCP4_CCP4_DIR}/ccp4_program.c
)

set(CCP4_MMDB_FILES
  ${CCP4_MMDB_DIR}/hybrid_36.cpp
  ${CCP4_MMDB_DIR}/mmdb_atom.cpp
  ${CCP4_MMDB_DIR}/mmdb_bondmngr.cpp
  ${CCP4_MMDB_DIR}/mmdb_chain.cpp
  ${CCP4_MMDB_DIR}/mmdb_cifdefs.cpp
  ${CCP4_MMDB_DIR}/mmdb_coormngr.cpp
  ${CCP4_MMDB_DIR}/mmdb_cryst.cpp
  ${CCP4_MMDB_DIR}/mmdb_ficif.cpp
  ${CCP4_MMDB_DIR}/mmdb_io_file.cpp
  ${CCP4_MMDB_DIR}/mmdb_io_stream.cpp
  ${CCP4_MMDB_DIR}/mmdb_machine_.cpp
  ${CCP4_MMDB_DIR}/mmdb_manager.cpp
  ${CCP4_MMDB_DIR}/mmdb_mask.cpp
  ${CCP4_MMDB_DIR}/mmdb_math_align.cpp
  ${CCP4_MMDB_DIR}/mmdb_math_bfgsmin.cpp
  ${CCP4_MMDB_DIR}/mmdb_math_.cpp
  ${CCP4_MMDB_DIR}/mmdb_math_fft.cpp
  ${CCP4_MMDB_DIR}/mmdb_math_graph.cpp
  ${CCP4_MMDB_DIR}/mmdb_math_linalg.cpp
  ${CCP4_MMDB_DIR}/mmdb_math_rand.cpp
  ${CCP4_MMDB_DIR}/mmdb_mattype.cpp
  ${CCP4_MMDB_DIR}/mmdb_mmcif_.cpp
  ${CCP4_MMDB_DIR}/mmdb_model.cpp
  ${CCP4_MMDB_DIR}/mmdb_root.cpp
  ${CCP4_MMDB_DIR}/mmdb_rwbrook.cpp
  ${CCP4_MMDB_DIR}/mmdb_selmngr.cpp
  ${CCP4_MMDB_DIR}/mmdb_seqsuperpose.cpp
  ${CCP4_MMDB_DIR}/mmdb_symop.cpp
  ${CCP4_MMDB_DIR}/mmdb_tables.cpp
  ${CCP4_MMDB_DIR}/mmdb_title.cpp
  ${CCP4_MMDB_DIR}/mmdb_uddata.cpp
  ${CCP4_MMDB_DIR}/mmdb_utils.cpp
  ${CCP4_MMDB_DIR}/mmdb_xml_.cpp
)

set(CCP4_SSM_FILES
  ${CCP4_SSM_DIR}/ssm_csia.cpp
  ${CCP4_SSM_DIR}/ssm_graph.cpp
  ${CCP4_SSM_DIR}/ssm_vxedge.cpp
  ${CCP4_SSM_DIR}/ssm_align.cpp
  ${CCP4_SSM_DIR}/ssm_superpose.cpp
  ${CCP4_SSM_DIR}/ssm_malign.cpp
)

# The ccp4io_adaptbx sources: printf wrappers, fortran call stubs and the
# Python extension itself.
add_library(ccp4io STATIC
  ${CCP4_C_FILES}
  ${CCP4_FORTRAN_C_FILES}
  ${CCP4_SINGLE_C_FILES}
  ${CCP4_MMDB_FILES}
  ${CCP4_SSM_FILES}
  ${ADAPBX_DIR}/fortran_call_stubs.c
  ${ADAPBX_DIR}/printf_wrappers.c
)
target_include_directories(ccp4io PUBLIC
  ${CCP4IO_SOURCE_DIR}
  ${CCP4_CCP4_DIR}
  ${CCP4_FORTRAN_DIR}
  ${CCP4_MMDB_DIR}
  ${CCP4_SSM_DIR}
  ${CCP4IO_ADAPTBX_SOURCE_DIR}/..
)
target_compile_definitions(ccp4io PUBLIC
  MSETS=32
  MXTALS=32
  MCOLUMNS=128
  USE_CALL_LIKE_SUN
)
target_link_libraries(ccp4io PUBLIC m Threads::Threads)

# Build the Python extension. It includes the vendored headers plus the CCTBX
# repository headers for scitbx/boost_adaptbx.
Python3_add_library(ccp4io_adaptbx_ext MODULE ${ADAPBX_DIR}/ext.cpp WITH_SOABI)
target_link_libraries(ccp4io_adaptbx_ext PRIVATE
  ccp4io
  Python3::Module
  Boost::${_boost_python_component}
  ${CMAKE_DL_LIBS}
)
target_include_directories(ccp4io_adaptbx_ext PRIVATE
  ${CCP4IO_ADAPTBX_SOURCE_DIR}
  ${CCP4IO_SOURCE_DIR}
  ${CCP4_CCP4_DIR}
  ${CCP4_MMDB_DIR}
  ${CCP4_SSM_DIR}
  ${CCTBX_SOURCE_DIR}
)
set_target_properties(ccp4io_adaptbx_ext PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/python"
)
install(TARGETS ccp4io_adaptbx_ext
  LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages"
)
# Install the Python package sources (the __init__.py module).
install(DIRECTORY ${CCP4IO_ADAPTBX_SOURCE_DIR}/
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages"
  FILES_MATCHING PATTERN "*.py"
)
