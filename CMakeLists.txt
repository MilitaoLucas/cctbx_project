cmake_minimum_required(VERSION 3.20)
project(cctbx_project VERSION 2025.10 LANGUAGES C CXX)

# Set CMake policies
if(POLICY CMP0167)
    cmake_policy(SET CMP0167 OLD)  # Continue to use FindBoost module
endif()

# Set C++ standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set C standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Export compile commands for IDEs
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Options
option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(ENABLE_OPENMP "Enable OpenMP support" OFF)
option(ENABLE_CUDA "Enable CUDA support" OFF)
option(ENABLE_KOKKOS "Enable Kokkos support" OFF)
option(ENABLE_BOOST_THREADS "Enable Boost.Thread support" ON)
option(USE_CONDA "Use Conda environment" OFF)

# Find Python
if (DEFINED Python_EXECUTABLE)
  get_filename_component(Python_HOME ${Python_EXECUTABLE} DIRECTORY)
  get_filename_component(Python_HOME ${Python_HOME} DIRECTORY)
  set(Python_INCLUDE_DIR "${Python_HOME}/include/python${Python_VERSION}")
endif ()
find_package(OpenSSL REQUIRED)
include_directories(${OPENSSL_INCLUDE_DIR})

set(Python_FIND_VIRTUALENV "ONLY")
set(Python_FIND_STRATEGY "LOCATION")
find_package(Python3 REQUIRED COMPONENTS Interpreter Development)
message(STATUS "Python3_EXECUTABLE: ${Python3_EXECUTABLE}")
message(STATUS "Python3_INCLUDE_DIRS: ${Python3_INCLUDE_DIRS}")
message(STATUS "Python3_LIBRARIES: ${Python3_LIBRARIES}")
include_directories(".venv/lib/python3.13/site-packages/ccp4io/libccp4/ccp4")
# Get Python site-packages directory for finding installed libraries (like CCP4)
execute_process(
    COMMAND ${Python3_EXECUTABLE} -c "import site; print(site.getsitepackages()[0])"
    OUTPUT_VARIABLE Python3_SITELIB
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
message(STATUS "Python3_SITELIB: ${Python3_SITELIB}")

# Add Python site-packages include and lib directories
if(EXISTS "${Python3_SITELIB}/include")
    include_directories("${Python3_SITELIB}/include")
    message(STATUS "Added Python site-packages include: ${Python3_SITELIB}/include")
endif()
if(EXISTS "${Python3_SITELIB}/lib")
    link_directories("${Python3_SITELIB}/lib")
    message(STATUS "Added Python site-packages lib: ${Python3_SITELIB}/lib")
endif()

# Also check for venv/virtualenv library paths
get_filename_component(Python3_PREFIX "${Python3_EXECUTABLE}" DIRECTORY)
get_filename_component(Python3_PREFIX "${Python3_PREFIX}" DIRECTORY)
if(EXISTS "${Python3_PREFIX}/include")
    include_directories("${Python3_PREFIX}/include")
    message(STATUS "Added Python env include: ${Python3_PREFIX}/include")
endif()
if(EXISTS "${Python3_PREFIX}/lib")
    link_directories("${Python3_PREFIX}/lib")
    message(STATUS "Added Python env lib: ${Python3_PREFIX}/lib")
endif()

# Find Boost
set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)

set(BOOST_COMPONENTS python numpy)
if(ENABLE_BOOST_THREADS)
    list(APPEND BOOST_COMPONENTS thread system chrono)
endif()

find_package(Boost 1.60 REQUIRED COMPONENTS ${BOOST_COMPONENTS})
message(STATUS "Boost_VERSION: ${Boost_VERSION}")
message(STATUS "Boost_INCLUDE_DIRS: ${Boost_INCLUDE_DIRS}")
message(STATUS "Boost_LIBRARIES: ${Boost_LIBRARIES}")

# Find HDF5
find_package(HDF5 COMPONENTS C)
if(HDF5_FOUND)
    message(STATUS "HDF5 found: ${HDF5_VERSION}")
endif()

# Find Eigen3
find_package(Eigen3 QUIET)
if(EIGEN3_FOUND)
    message(STATUS "Eigen3 found: ${EIGEN3_VERSION}")
    include_directories(${EIGEN3_INCLUDE_DIR})
else()
    message(STATUS "Eigen3 not found - some features may be disabled")
endif()

include_directories(${CMAKE_SOURCE_DIR}/cctbx/uctbx/lrl/LatticeRepLib/LatticeRepresentationLib)
include_directories(${CMAKE_SOURCE_DIR}/cctbx/uctbx/lrl/LatticeRepLib/LRL_Tools)
# OpenMP support
if(ENABLE_OPENMP)
    find_package(OpenMP)
    if(OPENMP_FOUND)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    endif()
endif()

# CUDA support
if(ENABLE_CUDA)
    enable_language(CUDA)
    find_package(CUDAToolkit)
endif()

# Global include directories
include_directories(
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_BINARY_DIR}/include
    ${Python3_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
)

# Global definitions
add_compile_definitions(
    BOOST_PYTHON_MAX_BASES=2
)

# Compiler-specific settings
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wno-sign-compare)
    if(CMAKE_BUILD_TYPE MATCHES "Release")
        add_compile_options(-O3)
    endif()
elseif(MSVC)
    add_compile_options(/W3 /EHsc)
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
endif()

# Platform-specific settings
if(WIN32)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
    add_compile_definitions(WIN32_LEAN_AND_MEAN)
elseif(APPLE)
    set(CMAKE_MACOSX_RPATH ON)
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ON)
endif()

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Python module output directory
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/lib)

# Create include directory for generated headers
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/include)

# Top-level target to generate all source files
add_custom_target(generate_sources
    COMMENT "Generating all required source files for all modules"
)

# Helper function to add Python extension modules
function(add_python_module MODULE_NAME)
    cmake_parse_arguments(ARG "" "" "SOURCES;LINK_LIBRARIES" ${ARGN})

    Python3_add_library(${MODULE_NAME} MODULE ${ARG_SOURCES})

    target_link_libraries(${MODULE_NAME} PRIVATE
        ${Boost_LIBRARIES}
        ${Python3_LIBRARIES}
        ${ARG_LINK_LIBRARIES}
    )

    # Set module properties
    set_target_properties(${MODULE_NAME} PROPERTIES
        PREFIX ""
        SUFFIX "${Python3_SOABI}.so"
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )

    if(APPLE)
        set_target_properties(${MODULE_NAME} PROPERTIES
            SUFFIX ".so"
            LINK_FLAGS "-undefined dynamic_lookup"
        )
    endif()
endfunction()

# Helper function to create Python executable dispatcher scripts
function(add_python_executable EXECUTABLE_NAME PYTHON_SCRIPT)
    set(DISPATCHER_FILE ${CMAKE_BINARY_DIR}/bin/${EXECUTABLE_NAME})

    # Create a shell script dispatcher
    file(WRITE ${DISPATCHER_FILE}
"#!/bin/sh
# LIBTBX_DISPATCHER - Generated by CMake
exec ${Python3_EXECUTABLE} ${PYTHON_SCRIPT} \"$@\"
")

    # Make the script executable
    file(CHMOD ${DISPATCHER_FILE}
        PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
                    GROUP_READ GROUP_EXECUTE
                    WORLD_READ WORLD_EXECUTE)

    # Add to install target (optional)
    install(PROGRAMS ${DISPATCHER_FILE} DESTINATION bin)
endfunction()

# Add subdirectories for each module
# Note: Order matters due to dependencies

# Core infrastructure modules (Level 0 - no dependencies)
if(EXISTS ${CMAKE_SOURCE_DIR}/boost_adaptbx/CMakeLists.txt)
    add_subdirectory(boost_adaptbx)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/libtbx/CMakeLists.txt)
    add_subdirectory(libtbx)
endif()

# Scientific computing base (Level 1 - depends on libtbx)
if(EXISTS ${CMAKE_SOURCE_DIR}/scitbx/CMakeLists.txt)
    add_subdirectory(scitbx)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/omptbx/CMakeLists.txt)
    add_subdirectory(omptbx)
endif()

# Crystallography core (Level 2 - depends on scitbx)
if(EXISTS ${CMAKE_SOURCE_DIR}/cctbx/CMakeLists.txt)
    add_subdirectory(cctbx)
endif()

# File I/O modules (Level 2)
if(EXISTS ${CMAKE_SOURCE_DIR}/cbflib_adaptbx/CMakeLists.txt)
    add_subdirectory(cbflib_adaptbx)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/fable/CMakeLists.txt)
    add_subdirectory(fable)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/ucif/CMakeLists.txt)
    add_subdirectory(ucif)
endif()

# Advanced modules (Level 3 - depends on cctbx)
if(EXISTS ${CMAKE_SOURCE_DIR}/smtbx/CMakeLists.txt)
    add_subdirectory(smtbx)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/iotbx/CMakeLists.txt)
    add_subdirectory(iotbx)
endif()

# Macromolecular crystallography (Level 4 - depends on iotbx)
if(EXISTS ${CMAKE_SOURCE_DIR}/mmtbx/CMakeLists.txt)
    add_subdirectory(mmtbx)
endif()

# Data processing and analysis modules
if(EXISTS ${CMAKE_SOURCE_DIR}/spotfinder/CMakeLists.txt)
    add_subdirectory(spotfinder)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/rstbx/CMakeLists.txt)
    add_subdirectory(rstbx)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/serialtbx/CMakeLists.txt)
    add_subdirectory(serialtbx)
endif()

# Simulation modules
if(EXISTS ${CMAKE_SOURCE_DIR}/simtbx/CMakeLists.txt)
    add_subdirectory(simtbx)
endif()

# X-ray Free Electron Laser (XFEL) modules
if(EXISTS ${CMAKE_SOURCE_DIR}/xfel/CMakeLists.txt)
    add_subdirectory(xfel)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/prime/CMakeLists.txt)
    add_subdirectory(prime)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/iota/CMakeLists.txt)
    add_subdirectory(iota)
endif()

# Specialized computational modules
if(EXISTS ${CMAKE_SOURCE_DIR}/fast_linalg/CMakeLists.txt)
    add_subdirectory(fast_linalg)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/fftw3tbx/CMakeLists.txt)
    add_subdirectory(fftw3tbx)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/cma_es/CMakeLists.txt)
    add_subdirectory(cma_es)
endif()

# Parallel computing modules
if(EXISTS ${CMAKE_SOURCE_DIR}/cudatbx/CMakeLists.txt AND ENABLE_CUDA)
    add_subdirectory(cudatbx)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/kokkostbx/CMakeLists.txt AND ENABLE_KOKKOS)
    add_subdirectory(kokkostbx)
endif()

# External library adapters
if(EXISTS ${CMAKE_SOURCE_DIR}/clipper_adaptbx/CMakeLists.txt)
    add_subdirectory(clipper_adaptbx)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/chiltbx/CMakeLists.txt)
    add_subdirectory(chiltbx)
endif()

# GUI and visualization modules
if(EXISTS ${CMAKE_SOURCE_DIR}/gltbx/CMakeLists.txt)
    add_subdirectory(gltbx)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/wxtbx/CMakeLists.txt)
    add_subdirectory(wxtbx)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/qttbx/CMakeLists.txt)
    add_subdirectory(qttbx)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/crys3d/CMakeLists.txt)
    add_subdirectory(crys3d)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/cootbx/CMakeLists.txt)
    add_subdirectory(cootbx)
endif()

# Documentation and website
if(EXISTS ${CMAKE_SOURCE_DIR}/sphinx/CMakeLists.txt)
    add_subdirectory(sphinx)
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/cctbx_website/CMakeLists.txt)
    add_subdirectory(cctbx_website)
endif()

# Make top-level generate_sources depend on all module-specific generators
if(TARGET scitbx_generate_sources)
    add_dependencies(generate_sources scitbx_generate_sources)
endif()
if(TARGET cctbx_generate_sources)
    add_dependencies(generate_sources cctbx_generate_sources)
endif()

# Create a custom target that builds ALL libraries and extensions
add_custom_target(build_all_libs
    COMMENT "Building all CCTBX libraries and Python extensions"
)

# Collect all library targets that were created
set(ALL_LIB_TARGETS "")

# Helper macro to add targets to build_all_libs
macro(add_to_all_libs target_name)
    if(TARGET ${target_name})
        list(APPEND ALL_LIB_TARGETS ${target_name})
        add_dependencies(build_all_libs ${target_name})
    endif()
endmacro()

# Add all known library targets
# Boost adaptbx extensions
add_to_all_libs(boost_python_hybrid_times_ext)
add_to_all_libs(boost_python_meta_ext)
add_to_all_libs(boost_optional_ext)
add_to_all_libs(boost_rational_ext)
add_to_all_libs(std_pair_ext)
add_to_all_libs(boost_tuple_ext)
add_to_all_libs(boost_adaptbx_graph_ext)
add_to_all_libs(boost_adaptbx_graph_connected_component_algorithm_ext)
add_to_all_libs(boost_adaptbx_graph_breadth_first_search_ext)
add_to_all_libs(boost_adaptbx_graph_graph_structure_comparison_ext)
add_to_all_libs(boost_adaptbx_graph_maximum_clique_ext)
add_to_all_libs(boost_adaptbx_graph_min_cut_max_flow_ext)
add_to_all_libs(boost_adaptbx_graph_utility_ext)
add_to_all_libs(boost_adaptbx_graph_metric_ext)
add_to_all_libs(boost_adaptbx_graph_clustering_algorithm_ext)
add_to_all_libs(boost_adaptbx_boost_thread_test_ext)
add_to_all_libs(boost_adaptbx_python_streambuf_test_ext)

# Scitbx libraries
add_to_all_libs(scitbx_boost_python)
add_to_all_libs(scitbx_minpack)
add_to_all_libs(scitbx_slatec)

# Cctbx libraries
add_to_all_libs(cctbx)
add_to_all_libs(cctbx_sgtbx_asu)
add_to_all_libs(asymmetric_map)

# Omptbx library
add_to_all_libs(omptbx)

# Iotbx libraries
add_to_all_libs(iotbx_pdb)
add_to_all_libs(iotbx_xplor)
add_to_all_libs(iotbx_mtz)

# Smtbx libraries
add_to_all_libs(smtbx_refinement_constraints)

# Fast linalg library
add_to_all_libs(fast_linalg)

# Also make build_all_libs depend on generate_sources
add_dependencies(build_all_libs generate_sources)

# Auto-detect all Python extension modules by finding all *_ext targets
# This uses CMake's BUILDSYSTEM_TARGETS property to get all targets
get_property(all_targets DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY BUILDSYSTEM_TARGETS)
set(EXT_TARGET_COUNT 0)
foreach(target ${all_targets})
    # Add any target ending with _ext to build_all_libs
    if(target MATCHES ".*_ext$")
        add_to_all_libs(${target})
        math(EXPR EXT_TARGET_COUNT "${EXT_TARGET_COUNT} + 1")
    endif()
endforeach()

# Create a target that builds EVERYTHING (all targets)
add_custom_target(build_all
    COMMENT "Building all CCTBX targets (libraries, extensions, executables, tests)"
)

# Make build_all depend on generate_sources first
add_dependencies(build_all generate_sources)

# Add ALL targets to build_all (not just libraries and extensions)
foreach(target ${all_targets})
    # Exclude utility targets and the build_all target itself
    if(NOT target MATCHES "^(generate_sources|build_all_libs|build_all)$")
        if(TARGET ${target})
            add_dependencies(build_all ${target})
        endif()
    endif()
endforeach()

message(STATUS "")
message(STATUS "Custom build targets:")
message(STATUS "  generate_sources  - Generate all required source files")
message(STATUS "  build_all_libs    - Build all CCTBX libraries and extensions")
message(STATUS "                      (${EXT_TARGET_COUNT} extension modules detected)")
message(STATUS "  build_all         - Build ALL targets (libs, exts, exes, tests)")
message(STATUS "")

# Installation rules
install(DIRECTORY ${CMAKE_BINARY_DIR}/lib/
    DESTINATION lib
    FILES_MATCHING PATTERN "*.so"
)

install(DIRECTORY ${CMAKE_BINARY_DIR}/bin/
    DESTINATION bin
    USE_SOURCE_PERMISSIONS
)

# Print configuration summary
message(STATUS "")
message(STATUS "CCTBX Configuration Summary:")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Install prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "  C++ compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "  Python: ${Python3_VERSION}")
message(STATUS "  Boost: ${Boost_VERSION}")
message(STATUS "  OpenMP: ${ENABLE_OPENMP}")
message(STATUS "  CUDA: ${ENABLE_CUDA}")
message(STATUS "  Kokkos: ${ENABLE_KOKKOS}")
message(STATUS "")

