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
option(CCTBX_BUILD_IOTBX "Build the iotbx layer" OFF)
option(CCTBX_BUILD_MMTBX "Build the mmtbx layer" OFF)
option(CCTBX_BUILD_GUI "Build GUI components" OFF)
option(CCTBX_BUILD_XFEL "Build XFEL components" OFF)

set(CMAKE_CXX_STANDARD 17 CACHE STRING "C++ standard used by cctbx")
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(Python3 3.13 EXACT REQUIRED COMPONENTS Interpreter)
find_package(Threads REQUIRED)
find_package(Boost 1.70 REQUIRED)
find_package(Eigen3 3.3 REQUIRED NO_MODULE)

set(CCTBX_GENERATED_ARRAY_FAMILY_DIR
  "${CMAKE_CURRENT_BINARY_DIR}/include/scitbx/array_family")
set(CCTBX_GENERATED_ARRAY_FAMILY_STAMP
  "${CCTBX_GENERATED_ARRAY_FAMILY_DIR}/.generated")
set(CCTBX_GENERATED_CCTBX_FLEX_FWD
  "${CMAKE_CURRENT_BINARY_DIR}/include/cctbx/boost_python/flex_fwd.h")
set(CCTBX_GENERATED_SCITBX_FLEX_FWD
  "${CMAKE_CURRENT_BINARY_DIR}/include/scitbx/array_family/boost_python/flex_fwd.h")
set(CCTBX_GENERATED_TYPE_ID_EQ
  "${CMAKE_CURRENT_BINARY_DIR}/include/boost_adaptbx/type_id_eq.h")
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/include/cctbx/boost_python")
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/include/scitbx/array_family/boost_python")
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/include/boost_adaptbx")
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cctbx_flex_fwd.h.in"
  "${CCTBX_GENERATED_CCTBX_FLEX_FWD}"
  COPYONLY
)
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/scitbx_flex_fwd.h.in"
  "${CCTBX_GENERATED_SCITBX_FLEX_FWD}"
  COPYONLY
)
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/type_id_eq.h.in"
  "${CCTBX_GENERATED_TYPE_ID_EQ}"
  COPYONLY
)
add_custom_command(
  OUTPUT "${CCTBX_GENERATED_ARRAY_FAMILY_STAMP}"
  COMMAND ${CMAKE_COMMAND} -E make_directory
    "${CCTBX_GENERATED_ARRAY_FAMILY_DIR}/detail"
  COMMAND ${CMAKE_COMMAND} -E env
    "PYTHONPATH=${CMAKE_CURRENT_SOURCE_DIR}"
    "${Python3_EXECUTABLE}" -c
    "from scitbx.source_generators.array_family import generate_all; generate_all.refresh(r'${CCTBX_GENERATED_ARRAY_FAMILY_DIR}')"
  COMMAND ${CMAKE_COMMAND} -E touch "${CCTBX_GENERATED_ARRAY_FAMILY_STAMP}"
  DEPENDS
    scitbx/source_generators/array_family/generate_all.py
    scitbx/source_generators/array_family/generate_reductions.py
    scitbx/source_generators/array_family/generate_operator_traits_builtin.py
  VERBATIM
)
add_custom_target(cctbx_generated_headers
  DEPENDS
    "${CCTBX_GENERATED_ARRAY_FAMILY_STAMP}"
    "${CCTBX_GENERATED_CCTBX_FLEX_FWD}"
    "${CCTBX_GENERATED_SCITBX_FLEX_FWD}"
    "${CCTBX_GENERATED_TYPE_ID_EQ}")

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

add_library(scitbx_slatec SHARED scitbx/slatec/lib_c.c)
target_link_libraries(scitbx_slatec PRIVATE cctbx_build_options m)
set_target_properties(scitbx_slatec PROPERTIES OUTPUT_NAME scitbx_slatec)

set(CCTBX_CORE_SOURCES
  cctbx/eltbx/basic.cpp
  cctbx/eltbx/xray_scattering/it1992.cpp
  cctbx/eltbx/xray_scattering/wk1995.cpp
  cctbx/eltbx/xray_scattering/n_gaussian_raw.cpp
  cctbx/eltbx/xray_scattering/n_gaussian.cpp
  cctbx/eltbx/fp_fdp.cpp
  cctbx/eltbx/icsd_radii.cpp
  cctbx/eltbx/covalent_radii.cpp
  cctbx/eltbx/neutron.cpp
  cctbx/eltbx/tiny_pse.cpp
  cctbx/eltbx/wavelengths.cpp
  cctbx/eltbx/electron_scattering/peng1996.cpp
  cctbx/eltbx/attenuation_coefficient.cpp
  cctbx/miller/asu.cpp
  cctbx/miller/bins.cpp
  cctbx/miller/index_generator.cpp
  cctbx/miller/index_span.cpp
  cctbx/miller/match_bijvoet_mates.cpp
  cctbx/miller/match_indices.cpp
  cctbx/miller/match_multi_indices.cpp
  cctbx/miller/sym_equiv.cpp
  cctbx/sgtbx/bricks.cpp
  cctbx/sgtbx/change_of_basis_op.cpp
  cctbx/sgtbx/find_affine.cpp
  cctbx/sgtbx/group_codes.cpp
  cctbx/sgtbx/hall_in.cpp
  cctbx/sgtbx/lattice_tr.cpp
  cctbx/sgtbx/lattice_symmetry.cpp
  cctbx/sgtbx/miller.cpp
  cctbx/sgtbx/reciprocal_space_asu.cpp
  cctbx/sgtbx/reciprocal_space_ref_asu.cpp
  cctbx/sgtbx/rot_mx.cpp
  cctbx/sgtbx/rot_mx_info.cpp
  cctbx/sgtbx/row_echelon_solve.cpp
  cctbx/sgtbx/rt_mx.cpp
  cctbx/sgtbx/select_generators.cpp
  cctbx/sgtbx/seminvariant.cpp
  cctbx/sgtbx/site_symmetry.cpp
  cctbx/sgtbx/space_group.cpp
  cctbx/sgtbx/space_group_type.cpp
  cctbx/sgtbx/symbols.cpp
  cctbx/sgtbx/tensor_rank_2.cpp
  cctbx/sgtbx/tr_group.cpp
  cctbx/sgtbx/tr_vec.cpp
  cctbx/sgtbx/utils.cpp
  cctbx/sgtbx/wyckoff.cpp
  cctbx/sgtbx/reference_settings/hall_symbol_table.cpp
  cctbx/sgtbx/reference_settings/matrix_group_code_table.cpp
  cctbx/sgtbx/reference_settings/normalizer.cpp
  cctbx/sgtbx/reference_settings/wyckoff.cpp
  cctbx/uctbx/uctbx.cpp
  cctbx/uctbx/spoil_optimization.cpp
  cctbx/uctbx/crystal_orientation.cpp
)

add_library(cctbx_core SHARED ${CCTBX_CORE_SOURCES})
add_library(cctbx::core ALIAS cctbx_core)
add_dependencies(cctbx_core cctbx_generated_headers)
target_link_libraries(cctbx_core PUBLIC cctbx_build_options scitbx_slatec m)
target_include_directories(cctbx_core PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
)
set_target_properties(cctbx_core PROPERTIES OUTPUT_NAME cctbx)

if(CCTBX_BUILD_PYTHON)
  find_package(Python3 3.13 EXACT REQUIRED COMPONENTS Interpreter Development.Module NumPy)

  set(_boost_python_component "python${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR}")
  set(_boost_numpy_component "numpy${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR}")
  find_package(Boost 1.70 REQUIRED COMPONENTS
    ${_boost_python_component}
    ${_boost_numpy_component}
  )

  add_library(scitbx_boost_python SHARED
    scitbx/boost_python/utils.cpp
    scitbx/boost_python/slice.cpp
    scitbx/array_family/boost_python/utils.cpp
  )
  target_link_libraries(scitbx_boost_python PRIVATE
    cctbx_build_options
    Python3::Module
    Boost::${_boost_python_component}
  )
  target_include_directories(scitbx_boost_python PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}/include
  )

  function(cctbx_add_python_extension target)
    cmake_parse_arguments(ARG "" "" "SOURCES;LIBRARIES" ${ARGN})
    Python3_add_library(${target} MODULE ${ARG_SOURCES} WITH_SOABI)
    target_link_libraries(${target} PRIVATE
      cctbx_build_options
    Python3::Module
    Python3::NumPy
    Boost::${_boost_python_component}
    Boost::${_boost_numpy_component}
      ${ARG_LIBRARIES}
    )
    target_include_directories(${target} PRIVATE
      ${CMAKE_CURRENT_SOURCE_DIR}
      ${CMAKE_CURRENT_BINARY_DIR}/include
      Python3::NumPy
    )
    set_target_properties(${target} PROPERTIES
      LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/python"
    )
    install(TARGETS ${target}
      LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages"
    )
  endfunction()

  cctbx_add_python_extension(cctbx_array_family_flex_ext
    SOURCES
      cctbx/array_family/boost_python/flex_ext.cpp
      cctbx/array_family/boost_python/flex_hendrickson_lattman.cpp
      cctbx/array_family/boost_python/flex_miller_index.cpp
      cctbx/array_family/boost_python/flex_xray_scatterer.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )
  add_dependencies(cctbx_array_family_flex_ext cctbx_generated_headers)

  cctbx_add_python_extension(scitbx_array_family_flex_ext
    SOURCES
      scitbx/array_family/boost_python/flex_ext.cpp
      scitbx/array_family/boost_python/flex_grid.cpp
      scitbx/array_family/boost_python/flex_bool.cpp
      scitbx/array_family/boost_python/flex_size_t.cpp
      scitbx/array_family/boost_python/flex_int.cpp
      scitbx/array_family/boost_python/flex_float.cpp
      scitbx/array_family/boost_python/flex_double.cpp
      scitbx/array_family/boost_python/flex_double_matrix.cpp
      scitbx/array_family/boost_python/flex_complex_double.cpp
      scitbx/array_family/boost_python/flex_std_string.cpp
      scitbx/array_family/boost_python/flex_random.cpp
      scitbx/array_family/boost_python/flex_sort.cpp
      scitbx/array_family/boost_python/flex_histogram.cpp
      scitbx/array_family/boost_python/flex_weighted_histogram.cpp
      scitbx/array_family/boost_python/flex_mean_and_variance.cpp
      scitbx/array_family/boost_python/flex_median.cpp
      scitbx/array_family/boost_python/flex_linear_interpolation.cpp
      scitbx/array_family/boost_python/flex_vec3_double.cpp
      scitbx/array_family/boost_python/flex_vec2_double.cpp
      scitbx/array_family/boost_python/flex_vec3_int.cpp
      scitbx/array_family/boost_python/flex_sym_mat3_double.cpp
      scitbx/array_family/boost_python/flex_mat3_double.cpp
      scitbx/array_family/boost_python/flex_tiny_size_t_2.cpp
      scitbx/array_family/boost_python/loops.cpp
      scitbx/array_family/boost_python/show_sizes.cpp
      scitbx/array_family/boost_python/numpy_bridge.cpp
    LIBRARIES scitbx_boost_python
  )
  add_dependencies(scitbx_array_family_flex_ext cctbx_generated_headers)
  target_compile_definitions(scitbx_array_family_flex_ext PRIVATE
    SCITBX_HAVE_NUMPY_INCLUDE
  )

  cctbx_add_python_extension(cctbx_statistics_ext
    SOURCES cctbx/boost_python/statistics_ext.cpp
    LIBRARIES cctbx_core
  )
endif()

install(DIRECTORY
  cctbx scitbx libtbx boost boost_adaptbx smtbx iotbx
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages"
  FILES_MATCHING
    PATTERN "*.py"
    PATTERN "__pycache__" EXCLUDE
)
install(DIRECTORY cctbx scitbx DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/cctbx
  FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.hxx")
install(TARGETS cctbx_build_options cctbx_core scitbx_slatec
  EXPORT cctbxTargets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
if(CCTBX_BUILD_PYTHON)
  install(TARGETS scitbx_boost_python
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )
endif()

if(CCTBX_BUILD_TESTS)
  add_test(NAME cctbx_python_imports
    COMMAND ${Python3_EXECUTABLE} -c
      "import cctbx, scitbx"
  )
endif()

install(EXPORT cctbxTargets
  FILE cctbxTargets.cmake
  NAMESPACE cctbx::
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/cctbx"
)
