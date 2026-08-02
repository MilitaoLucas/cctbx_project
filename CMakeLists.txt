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
option(CCTBX_BUILD_SMTBX "Build the smtbx layer" ON)

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
    "PYTHONPATH=${CMAKE_CURRENT_SOURCE_DIR}:$ENV{PYTHONPATH}"
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
  cctbx/eltbx/sasaki_fallback.cpp
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
    chrono
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
  add_dependencies(scitbx_boost_python cctbx_generated_headers)

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
    add_dependencies(${target} cctbx_generated_headers)
    set_target_properties(${target} PROPERTIES
      LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/python"
    )
    install(TARGETS ${target}
      LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages"
    )
  endfunction()

  cctbx_add_python_extension(boost_python_meta_ext
    SOURCES boost_adaptbx/meta_ext.cpp
    LIBRARIES scitbx_boost_python
  )
  target_compile_definitions(boost_python_meta_ext PRIVATE USE_CONDA)

  cctbx_add_python_extension(boost_optional_ext
    SOURCES boost_adaptbx/optional_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(boost_tuple_ext
    SOURCES boost_adaptbx/tuple_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(std_pair_ext
    SOURCES boost_adaptbx/std_pair_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(boost_rational_ext
    SOURCES boost_adaptbx/rational_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_stl_set_ext
    SOURCES scitbx/stl/set_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_stl_vector_ext
    SOURCES scitbx/stl/vector_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_stl_map_ext
    SOURCES scitbx/stl/map_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_array_family_shared_ext
    SOURCES scitbx/array_family/boost_python/shared_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_linalg_ext
    SOURCES
      scitbx/linalg/boost_python/linalg_ext.cpp
      scitbx/linalg/boost_python/matrix.cpp
      scitbx/linalg/boost_python/cholesky.cpp
      scitbx/linalg/boost_python/householder.cpp
      scitbx/linalg/boost_python/svd.cpp
      scitbx/linalg/boost_python/eigensystem.cpp
      scitbx/linalg/boost_python/lapack_fem_bpl.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(cctbx_array_family_flex_ext
    SOURCES
      cctbx/array_family/boost_python/flex_ext.cpp
      cctbx/array_family/boost_python/flex_hendrickson_lattman.cpp
      cctbx/array_family/boost_python/flex_miller_index.cpp
      cctbx/array_family/boost_python/flex_xray_scatterer.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )

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
  target_compile_definitions(scitbx_array_family_flex_ext PRIVATE
    SCITBX_HAVE_NUMPY_INCLUDE
  )

  cctbx_add_python_extension(cctbx_statistics_ext
    SOURCES cctbx/boost_python/statistics_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_xray_ext
    SOURCES
      cctbx/xray/boost_python/xray_ext.cpp
      cctbx/xray/boost_python/conversions.cpp
      cctbx/xray/boost_python/gradient_flags.cpp
      cctbx/xray/boost_python/gradients_direct.cpp
      cctbx/xray/boost_python/each_hkl_gradients_direct.cpp
      cctbx/xray/boost_python/fast_gradients.cpp
      cctbx/xray/boost_python/minimization.cpp
      cctbx/xray/boost_python/scatterer_flags.cpp
      cctbx/xray/boost_python/scatterer.cpp
      cctbx/xray/boost_python/scattering_type_registry.cpp
      cctbx/xray/boost_python/sampling_base.cpp
      cctbx/xray/boost_python/sampled_model_density.cpp
      cctbx/xray/boost_python/structure_factors_direct.cpp
      cctbx/xray/boost_python/structure_factors_simple.cpp
      cctbx/xray/boost_python/curvatures_simple.cpp
      cctbx/xray/boost_python/targets.cpp
      cctbx/xray/boost_python/f_model_bpl.cpp
      cctbx/xray/boost_python/twin_targets.cpp
      cctbx/xray/boost_python/grouped_data.cpp
      cctbx/xray/boost_python/parameter_map.cpp
      cctbx/xray/boost_python/twin_components.cpp
      cctbx/xray/boost_python/thickness.cpp
      cctbx/xray/boost_python/extinction.cpp
      cctbx/xray/boost_python/dispersion_radial.cpp
      cctbx/xray/boost_python/sigmaa.cpp
      cctbx/xray/targets/shelxl_wght_ls_bpl.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )
  target_include_directories(cctbx_xray_ext PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/fable"
  )

  cctbx_add_python_extension(cctbx_eltbx_xray_scattering_ext
    SOURCES cctbx/eltbx/boost_python/xray_scattering_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_adptbx_ext
    SOURCES
      cctbx/adptbx/boost_python/adptbx_ext.cpp
      cctbx/adptbx/boost_python/hirshfeld.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_uctbx_ext
    SOURCES
      cctbx/uctbx/boost_python/uctbx_ext.cpp
      cctbx/uctbx/boost_python/fast_minimum_reduction.cpp
      cctbx/uctbx/boost_python/niggli_reduction.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_sgtbx_ext
    SOURCES
      cctbx/sgtbx/boost_python/sgtbx_ext.cpp
      cctbx/sgtbx/boost_python/brick.cpp
      cctbx/sgtbx/boost_python/change_of_basis.cpp
      cctbx/sgtbx/boost_python/find_affine.cpp
      cctbx/sgtbx/boost_python/lattice_symmetry.cpp
      cctbx/sgtbx/boost_python/phase_info.cpp
      cctbx/sgtbx/boost_python/reciprocal_space_asu.cpp
      cctbx/sgtbx/boost_python/rot_mx.cpp
      cctbx/sgtbx/boost_python/rt_mx.cpp
      cctbx/sgtbx/boost_python/search_symmetry.cpp
      cctbx/sgtbx/boost_python/seminvariant.cpp
      cctbx/sgtbx/boost_python/site_symmetry.cpp
      cctbx/sgtbx/boost_python/space_group.cpp
      cctbx/sgtbx/boost_python/space_group_type.cpp
      cctbx/sgtbx/boost_python/sym_equiv_sites.cpp
      cctbx/sgtbx/boost_python/symbols.cpp
      cctbx/sgtbx/boost_python/tensor_rank_2.cpp
      cctbx/sgtbx/boost_python/tensors.cpp
      cctbx/sgtbx/boost_python/tr_vec.cpp
      cctbx/sgtbx/boost_python/wyckoff.cpp
      cctbx/sgtbx/boost_python/select_generators.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_maptbx_ext
    SOURCES
      cctbx/maptbx/boost_python/maptbx_ext.cpp
      cctbx/maptbx/boost_python/grid_indices_around_sites.cpp
      cctbx/maptbx/boost_python/grid_tags.cpp
      cctbx/maptbx/boost_python/gridding.cpp
      cctbx/maptbx/boost_python/misc.cpp
      cctbx/maptbx/boost_python/peak_search.cpp
      cctbx/maptbx/boost_python/pymol_interface.cpp
      cctbx/maptbx/boost_python/statistics.cpp
      cctbx/maptbx/boost_python/structure_factors.cpp
      cctbx/maptbx/boost_python/coordinate_transformers.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_crystal_ext
    SOURCES
      cctbx/crystal/crystal_ext.cpp
      cctbx/crystal/asu_clusters_bpl.cpp
      cctbx/crystal/close_packing_bpl.cpp
      cctbx/crystal/coordination_sequences_bpl.cpp
      cctbx/crystal/direct_space_asu_bpl.cpp
      cctbx/crystal/incremental_pairs_bpl.cpp
      cctbx/crystal/neighbors_bpl.cpp
      cctbx/crystal/pair_tables_bpl.cpp
      cctbx/crystal/site_cluster_analysis_bpl.cpp
      cctbx/crystal/symmetry_bpl.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_covariance_ext
    SOURCES cctbx/covariance/boost_python/covariance_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_geometry_ext
    SOURCES cctbx/geometry/boost_python/geometry_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(scitbx_cubicle_neighbors_ext
    SOURCES scitbx/cubicle_neighbors_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_fftpack_ext
    SOURCES scitbx/fftpack/boost_python/fftpack_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(cctbx_math_ext
    SOURCES cctbx/math/boost_python/math_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(scitbx_math_ext
    SOURCES
      scitbx/math/boost_python/math_ext.cpp
      scitbx/math/boost_python/basic_statistics.cpp
      scitbx/math/boost_python/gaussian.cpp
      scitbx/math/boost_python/golay.cpp
      scitbx/math/boost_python/minimum_covering_sphere.cpp
      scitbx/math/boost_python/principal_axes_of_inertia.cpp
      scitbx/math/boost_python/row_echelon.cpp
      scitbx/math/boost_python/tensor_rank_2.cpp
      scitbx/math/boost_python/chebyshev.cpp
      scitbx/math/boost_python/icosahedron.cpp
      scitbx/math/boost_python/slatec.cpp
      scitbx/math/boost_python/line_search.cpp
      scitbx/math/boost_python/r3_rotation.cpp
      scitbx/math/boost_python/resample.cpp
      scitbx/math/boost_python/quadrature.cpp
      scitbx/math/boost_python/unimodular_generator.cpp
      scitbx/math/boost_python/halton.cpp
      scitbx/math/boost_python/least_squares_plane.cpp
      scitbx/math/boost_python/continued_fraction.cpp
      scitbx/math/boost_python/numeric_limits.cpp
      scitbx/math/boost_python/distributions.cpp
      scitbx/math/boost_python/exp_functions.cpp
      scitbx/math/boost_python/zernike.cpp
      scitbx/math/boost_python/zernike_moments.cpp
      scitbx/math/boost_python/2d_zernike_moments.cpp
      scitbx/math/boost_python/weighted_covariance.cpp
      scitbx/math/boost_python/rotation.cpp
      scitbx/math/boost_python/interpolation.cpp
      scitbx/math/boost_python/tetrahedron.cpp
      scitbx/math/boost_python/angle_derivative.cpp
    LIBRARIES scitbx_slatec scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_random_ext
    SOURCES
      scitbx/random/boost_python/random_ext.cpp
      scitbx/random/boost_python/basic_distributions.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_sparse_ext
    SOURCES
      scitbx/sparse/boost_python/vector.cpp
      scitbx/sparse/boost_python/matrix.cpp
      scitbx/sparse/boost_python/approx_equal.cpp
      scitbx/sparse/boost_python/random.cpp
      scitbx/sparse/boost_python/lu_factorization.cpp
      scitbx/sparse/boost_python/sparse_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  if(CCTBX_BUILD_SMTBX)
    add_library(smtbx_refinement_constraints SHARED
      smtbx/refinement/constraints/affine.cpp
      smtbx/refinement/constraints/geometrical_hydrogens.cpp
      smtbx/refinement/constraints/occupancy.cpp
      smtbx/refinement/constraints/reparametrisation.cpp
      smtbx/refinement/constraints/rigid.cpp
      smtbx/refinement/constraints/same_group.cpp
      smtbx/refinement/constraints/scaled_adp.cpp
      smtbx/refinement/constraints/shared.cpp
      smtbx/refinement/constraints/special_position.cpp
      smtbx/refinement/constraints/symmetry_equivalent.cpp
      smtbx/refinement/constraints/u_eq_dependent_u_iso.cpp
      smtbx/refinement/constraints/u_iso_dependent_u_iso.cpp
    )
    target_link_libraries(smtbx_refinement_constraints PUBLIC
      cctbx_core
      scitbx_boost_python
      cctbx_build_options
    )
    target_include_directories(smtbx_refinement_constraints PUBLIC
      $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
      $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
    )
    set_target_properties(smtbx_refinement_constraints PROPERTIES
      OUTPUT_NAME smtbx_refinement_constraints
    )

    cctbx_add_python_extension(smtbx_array_family_ext
      SOURCES smtbx/array_family/af_ext.cpp
      LIBRARIES scitbx_boost_python cctbx_core
    )

    cctbx_add_python_extension(smtbx_stl_map_ext
      SOURCES smtbx/stl/map_ext.cpp
      LIBRARIES scitbx_boost_python
    )

    cctbx_add_python_extension(smtbx_refinement_constraints_ext
      SOURCES
        smtbx/refinement/constraints/boost_python/constraints_ext.cpp
        smtbx/refinement/constraints/boost_python/affine.cpp
        smtbx/refinement/constraints/boost_python/direction.cpp
        smtbx/refinement/constraints/boost_python/geometrical_hydrogens.cpp
        smtbx/refinement/constraints/boost_python/independent_scalar_parameters.cpp
        smtbx/refinement/constraints/boost_python/occupancy.cpp
        smtbx/refinement/constraints/boost_python/reparametrisation.cpp
        smtbx/refinement/constraints/boost_python/rigid.cpp
        smtbx/refinement/constraints/boost_python/same_group.cpp
        smtbx/refinement/constraints/boost_python/scaled_adp.cpp
        smtbx/refinement/constraints/boost_python/scatterer_parameters.cpp
        smtbx/refinement/constraints/boost_python/shared.cpp
        smtbx/refinement/constraints/boost_python/special_position.cpp
        smtbx/refinement/constraints/boost_python/symmetry_equivalent.cpp
        smtbx/refinement/constraints/boost_python/u_eq_dependent_u_iso.cpp
        smtbx/refinement/constraints/boost_python/u_iso_dependent_u_iso.cpp
      LIBRARIES smtbx_refinement_constraints scitbx_boost_python
    )

    cctbx_add_python_extension(smtbx_refinement_restraints_ext
      SOURCES
        smtbx/refinement/restraints/boost_python/restraints_ext.cpp
        smtbx/refinement/restraints/boost_python/origin_fixing.cpp
      LIBRARIES cctbx_core scitbx_boost_python
    )

    add_library(smtbx_ed_data SHARED smtbx/ED/dyn_calculator.cpp)
    target_link_libraries(smtbx_ed_data PUBLIC
      cctbx_core
      scitbx_boost_python
      cctbx_build_options
    )
    target_include_directories(smtbx_ed_data PUBLIC
      $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
      $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
    )
    set_target_properties(smtbx_ed_data PROPERTIES OUTPUT_NAME smtbx_ed_data)

    cctbx_add_python_extension(smtbx_ed_data_ext
      SOURCES smtbx/ED/boost_python/ed_data.cpp
      LIBRARIES smtbx_ed_data scitbx_boost_python
    )

    cctbx_add_python_extension(smtbx_refinement_least_squares_ext
      SOURCES
        smtbx/refinement/boost_python/least_squares_ext.cpp
        smtbx/refinement/boost_python/least_squares.cpp
        smtbx/refinement/boost_python/weighting_schemes.cpp
      LIBRARIES
        smtbx_refinement_constraints
        smtbx_ed_data
        scitbx_boost_python
        Boost::chrono
    )

    cctbx_add_python_extension(smtbx_structure_factors_direct_ext
      SOURCES
        smtbx/structure_factors/direct/boost_python/ext.cpp
        smtbx/structure_factors/direct/boost_python/standard_xray.cpp
      LIBRARIES cctbx_core scitbx_boost_python
    )
  endif()
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
set(CCTBX_NATIVE_TARGETS cctbx_build_options cctbx_core scitbx_slatec)
if(CCTBX_BUILD_PYTHON AND CCTBX_BUILD_SMTBX)
  list(APPEND CCTBX_NATIVE_TARGETS smtbx_refinement_constraints smtbx_ed_data)
endif()
install(TARGETS ${CCTBX_NATIVE_TARGETS}
  EXPORT cctbxTargets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
if(CCTBX_BUILD_PYTHON)
  install(TARGETS scitbx_boost_python
    EXPORT cctbxTargets
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
