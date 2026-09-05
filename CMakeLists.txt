cmake_minimum_required(VERSION 3.25)

if(POLICY CMP0167)
  cmake_policy(SET CMP0167 NEW)
endif()
if(POLICY CMP0169)
  # FetchContent_Populate is used for non-CMake (autotools) ccp4io sources.
  cmake_policy(SET CMP0169 OLD)
endif()
if(POLICY CMP0177)
  cmake_policy(SET CMP0177 NEW)
endif()

project(cctbx
  VERSION 0.0.0
  LANGUAGES C CXX
)

include(GNUInstallDirs)
include(CTest)

# Keep the library destination stable ("lib") across hosts and prefixes so the
# wheel RPATH and the nix PYTHONPATH both resolve to a predictable location.
# (Re-declared as a normal variable; GNUInstallDirs may have set a non-cache
# default that a cache variable cannot override.)
set(CMAKE_INSTALL_LIBDIR "lib")

option(CCTBX_BUILD_PYTHON "Build Python extension modules" ON)
option(CCTBX_BUILD_TESTS "Build CTest targets" OFF)
option(CCTBX_BUILD_SMTBX "Build the smtbx layer" ON)
option(CCTBX_USE_CCP4IO "Build the ccp4io-dependent iotbx extensions" OFF)
option(CCTBX_USE_FETCHED_CCP4IO "Fetch and build ccp4io and ccp4io_adaptbx from source" OFF)
option(CCTBX_WHEEL "Build for a distributable Python wheel" OFF)

# Python major.minor to build against. Not hardcoded so the same tree can be
# built for other Python versions; the default matches the testing environment.
set(CCTBX_PYTHON_VERSION "3.13" CACHE STRING "Python major.minor version")

set(CMAKE_CXX_STANDARD 17 CACHE STRING "C++ standard used by cctbx")
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(Python3 ${CCTBX_PYTHON_VERSION} EXACT REQUIRED COMPONENTS Interpreter)
find_package(Threads REQUIRED)
find_package(OpenMP REQUIRED)
find_package(Boost 1.70 REQUIRED)
find_package(Eigen3 3.3 REQUIRED NO_MODULE)

if(CCTBX_BUILD_PYTHON)
  find_package(Python3 ${CCTBX_PYTHON_VERSION} EXACT REQUIRED COMPONENTS Interpreter Development.Module NumPy)

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

# Destination for Python packages and extension modules. Defaults to the
# standard site-packages layout; the wheel build overrides it with "." so the
# CMake install output lands at the wheel root.
set(CCTBX_PYTHON_INSTALL_DIR
  "${CMAKE_INSTALL_LIBDIR}/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages"
  CACHE STRING "Install destination for Python packages and extensions")

# A wheel bundles its own shared libraries, so place them next to the
# extensions and point the loader at them with an $ORIGIN-based RPATH.
if(CCTBX_WHEEL)
  set(CMAKE_INSTALL_RPATH "$ORIGIN")
  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ON)
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

if(CCTBX_USE_CCP4IO)
  if(CCTBX_USE_FETCHED_CCP4IO)
    include(FetchContent)
    set(CCTBX_CCP4IO_GIT_REV "b58c4fb68902e4e6a58f4a585d0722e542516076"
      CACHE STRING "ccp4io revision to fetch at build time")
    set(CCTBX_CCP4IO_ADAPTBX_GIT_REV "d8534cac262365e8a815f275cd1f1aa1650972cb"
      CACHE STRING "ccp4io_adaptbx revision to fetch at build time")
    FetchContent_Declare(ccp4io
      GIT_REPOSITORY https://github.com/cctbx/ccp4io.git
      GIT_TAG ${CCTBX_CCP4IO_GIT_REV}
      GIT_SHALLOW FALSE
    )
    FetchContent_Declare(ccp4io_adaptbx
      GIT_REPOSITORY https://github.com/cctbx/ccp4io_adaptbx.git
      GIT_TAG ${CCTBX_CCP4IO_ADAPTBX_GIT_REV}
      GIT_SHALLOW FALSE
    )
    FetchContent_GetProperties(ccp4io)
    if(NOT ccp4io_POPULATED)
      FetchContent_Populate(ccp4io)
    endif()
    FetchContent_GetProperties(ccp4io_adaptbx)
    if(NOT ccp4io_adaptbx_POPULATED)
      FetchContent_Populate(ccp4io_adaptbx)
    endif()
    # The vendored headers are included as <ccp4io_adaptbx/...>. Stage the
    # fetched sources under that real directory name (a symlink is resolved away
    # by the compiler before the trailing ".." is applied, so it must be a copy).
    set(_ccp4io_adaptbx_alias "${CMAKE_BINARY_DIR}/ccp4io_adaptbx")
    if(NOT EXISTS "${_ccp4io_adaptbx_alias}")
      file(COPY "${ccp4io_adaptbx_SOURCE_DIR}/"
        DESTINATION "${_ccp4io_adaptbx_alias}"
        PATTERN ".git" EXCLUDE
      )
    endif()
    set(CCP4IO_SOURCE_DIR "${ccp4io_SOURCE_DIR}")
    set(CCP4IO_ADAPTBX_SOURCE_DIR "${_ccp4io_adaptbx_alias}")
    include(cmake/cctbxCcp4io.cmake)
  else()
    # ccp4io provided externally (e.g. by Nix as a build input).
    find_library(CCP4IO_LIBRARY NAMES ccp4c REQUIRED)
    find_path(CCP4IO_INCLUDE_DIR NAMES cmtzlib.h PATH_SUFFIXES ccp4 REQUIRED)
    add_library(ccp4io UNKNOWN IMPORTED)
    set_target_properties(ccp4io PROPERTIES
      IMPORTED_LOCATION "${CCP4IO_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${CCP4IO_INCLUDE_DIR}"
    )
  endif()
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
  DESTINATION "${CCTBX_PYTHON_INSTALL_DIR}"
  FILES_MATCHING
    PATTERN "*.py"
    PATTERN "__pycache__" EXCLUDE
)
install(DIRECTORY cctbx scitbx DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/cctbx
  FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.hxx")

if(CCTBX_BUILD_PYTHON)
  # Install the generated libtbx_env where env_config.get_installed_path()
  # locates it for a non-conda install (site-packages/libtbx/core/share/cctbx).
  set(_cctbx_env_install_dir "${CCTBX_PYTHON_INSTALL_DIR}/libtbx/core/share/cctbx")
  install(FILES "${CMAKE_BINARY_DIR}/cctbx_build/libtbx_env"
    DESTINATION "${_cctbx_env_install_dir}"
  )
  if(CCTBX_WHEEL)
    # Rewrite the libtbx_env module paths so they resolve from the wheel root;
    # the Nix build performs its own post-install env rewrite instead.
    install(CODE "
      set(ENV{PREFIX} \"\${CMAKE_INSTALL_PREFIX}\")
      set(ENV{PYTHONPATH} \"\${CMAKE_INSTALL_PREFIX}:$ENV{PYTHONPATH}\")
      execute_process(
        COMMAND \"${Python3_EXECUTABLE}\"
          \"${PROJECT_SOURCE_DIR}/cmake/update_wheel_libtbx_env.py\"
        RESULT_VARIABLE _rc
        OUTPUT_VARIABLE _out
        ERROR_VARIABLE _err
      )
      if(NOT _rc EQUAL 0)
        message(FATAL_ERROR \"update_wheel_libtbx_env failed (rc=\${_rc}):\n\${_out}\n\${_err}\")
      endif()
    ")
  endif()
endif()

if(CCTBX_WHEEL AND CCTBX_BUILD_PYTHON)
  # Bundle the Boost runtime shared libraries into the wheel so it is
  # relocatable across machines. The extensions link libboost_python<n>,
  # libboost_numpy<n> and transitively the other libboost components.
  set(_boost_targets
    Boost::python
    Boost::numpy
    Boost::thread
    Boost::chrono
    Boost::timer
  )
  set(_boost_lib_dirs "")
  foreach(_t IN LISTS _boost_targets)
    if(TARGET ${_t})
      get_target_property(_loc ${_t} IMPORTED_LOCATION_RELEASE)
      if(NOT _loc OR _loc MATCHES "-NOTFOUND")
        get_target_property(_loc ${_t} IMPORTED_LOCATION)
      endif()
      if(_loc AND NOT _loc MATCHES "-NOTFOUND")
        get_filename_component(_d "${_loc}" DIRECTORY)
        list(APPEND _boost_lib_dirs "${_d}")
      endif()
    endif()
  endforeach()
  list(REMOVE_DUPLICATES _boost_lib_dirs)
  set(_boost_files "")
  foreach(_d IN LISTS _boost_lib_dirs)
    file(GLOB _f "${_d}/libboost*.so*")
    list(APPEND _boost_files ${_f})
  endforeach()
  list(REMOVE_DUPLICATES _boost_files)
  if(_boost_files)
    install(FILES ${_boost_files} DESTINATION "${CMAKE_INSTALL_LIBDIR}")
  endif()
endif()

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
