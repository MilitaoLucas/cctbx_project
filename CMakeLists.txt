cmake_minimum_required(VERSION 3.25)

if(POLICY CMP0167)
  cmake_policy(SET CMP0167 NEW)
endif()

project(cctbx
  VERSION 0.0.0
  LANGUAGES C CXX
)

include(GNUInstallDirs)
include(CTest)

option(CCTBX_BUILD_PYTHON "Build Python extension modules" ON)
option(CCTBX_BUILD_TESTS "Build CTest targets" OFF)
option(CCTBX_BUILD_SMTBX "Build the smtbx layer" ON)
option(CCTBX_USE_CCP4IO "Build the ccp4io-dependent iotbx extensions" OFF)

set(CMAKE_CXX_STANDARD 17 CACHE STRING "C++ standard used by cctbx")
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(Python3 3.13 EXACT REQUIRED COMPONENTS Interpreter)
find_package(Threads REQUIRED)
find_package(OpenMP REQUIRED)
find_package(Boost 1.70 REQUIRED)
find_package(Eigen3 3.3 REQUIRED NO_MODULE)

if(CCTBX_BUILD_PYTHON)
  find_package(Python3 3.13 EXACT REQUIRED COMPONENTS Interpreter Development.Module NumPy)

  set(_boost_python_component "python${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR}")
  set(_boost_numpy_component "numpy${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR}")
  find_package(Boost 1.70 REQUIRED COMPONENTS
    ${_boost_python_component}
    ${_boost_numpy_component}
    chrono
    timer
    thread
  )
endif()

if(CCTBX_USE_CCP4IO)
  find_library(CCP4IO_LIBRARY NAMES ccp4c REQUIRED)
  find_path(CCP4IO_INCLUDE_DIR NAMES cmtzlib.h PATH_SUFFIXES ccp4 REQUIRED)
  add_library(ccp4io UNKNOWN IMPORTED)
  set_target_properties(ccp4io PROPERTIES
    IMPORTED_LOCATION "${CCP4IO_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${CCP4IO_INCLUDE_DIR}"
  )
endif()

include(cmake/cctbxGeneratedHeaders.cmake)
include(cmake/cctbxLibtbxEnv.cmake)
include(cmake/cctbxPythonExtension.cmake)

add_library(cctbx_build_options INTERFACE)
target_compile_definitions(cctbx_build_options INTERFACE
  BOOST_ALL_NO_LIB
  BOOST_PYTHON_MAX_BASES=2
)
target_include_directories(cctbx_build_options INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/cctbx>
)
target_link_libraries(cctbx_build_options INTERFACE Threads::Threads ${CMAKE_DL_LIBS})

install(TARGETS cctbx_build_options
  EXPORT cctbxTargets
)

if(CCTBX_BUILD_PYTHON)
  cctbx_generate_libtbx_env()
endif()

add_subdirectory(cma_es)
add_subdirectory(fable)
add_subdirectory(fast_linalg)
add_subdirectory(omptbx)
add_subdirectory(scitbx)
add_subdirectory(cctbx)
add_subdirectory(boost_adaptbx)
add_subdirectory(iotbx)
add_subdirectory(mmtbx)
add_subdirectory(smtbx)
add_subdirectory(xcif)

install(DIRECTORY
  cctbx scitbx libtbx boost boost_adaptbx smtbx iotbx
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages"
  FILES_MATCHING
    PATTERN "*.py"
    PATTERN "__pycache__" EXCLUDE
)
install(DIRECTORY cctbx scitbx DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/cctbx
  FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.hxx")

if(CCTBX_BUILD_TESTS AND CCTBX_BUILD_PYTHON)
  add_test(NAME cctbx_python_imports
    COMMAND ${Python3_EXECUTABLE} -c
      "import cctbx, scitbx"
  )
  set_tests_properties(cctbx_python_imports PROPERTIES
    ENVIRONMENT
      "LIBTBX_BUILD=${CMAKE_BINARY_DIR}/cctbx_build;PYTHONPATH=${CMAKE_BINARY_DIR}/python:${CMAKE_CURRENT_SOURCE_DIR}"
  )
endif()

install(EXPORT cctbxTargets
  FILE cctbxTargets.cmake
  NAMESPACE cctbx::
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/cctbx"
)
