add_library(scitbx_slatec SHARED slatec/lib_c.c)
target_link_libraries(scitbx_slatec PRIVATE cctbx_build_options m)
set_target_properties(scitbx_slatec PROPERTIES OUTPUT_NAME scitbx_slatec)

add_library(scitbx_minpack SHARED minpack/raw.cpp)
target_link_libraries(scitbx_minpack PUBLIC cctbx_build_options m)
set_target_properties(scitbx_minpack PROPERTIES OUTPUT_NAME scitbx_minpack)

install(TARGETS scitbx_slatec scitbx_minpack
  EXPORT cctbxTargets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

if(CCTBX_BUILD_PYTHON)
  add_library(scitbx_boost_python SHARED
    boost_python/utils.cpp
    boost_python/slice.cpp
    array_family/boost_python/utils.cpp
  )
  target_link_libraries(scitbx_boost_python PRIVATE
    cctbx_build_options
    Python3::Module
    Boost::${_boost_python_component}
  )
  target_include_directories(scitbx_boost_python PRIVATE
    ${PROJECT_SOURCE_DIR}
    ${PROJECT_BINARY_DIR}/include
  )
  add_dependencies(scitbx_boost_python cctbx_generated_headers)
  install(TARGETS scitbx_boost_python
    EXPORT cctbxTargets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

  cctbx_add_python_extension(scitbx_stl_set_ext
    SOURCES stl/set_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_stl_vector_ext
    SOURCES stl/vector_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_stl_map_ext
    SOURCES stl/map_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_array_family_shared_ext
    SOURCES array_family/boost_python/shared_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_linalg_ext
    SOURCES
      linalg/boost_python/linalg_ext.cpp
      linalg/boost_python/matrix.cpp
      linalg/boost_python/cholesky.cpp
      linalg/boost_python/householder.cpp
      linalg/boost_python/svd.cpp
      linalg/boost_python/eigensystem.cpp
      linalg/boost_python/lapack_fem_bpl.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_array_family_flex_ext
    SOURCES
      array_family/boost_python/flex_ext.cpp
      array_family/boost_python/flex_grid.cpp
      array_family/boost_python/flex_bool.cpp
      array_family/boost_python/flex_size_t.cpp
      array_family/boost_python/flex_int.cpp
      array_family/boost_python/flex_float.cpp
      array_family/boost_python/flex_double.cpp
      array_family/boost_python/flex_double_matrix.cpp
      array_family/boost_python/flex_complex_double.cpp
      array_family/boost_python/flex_std_string.cpp
      array_family/boost_python/flex_random.cpp
      array_family/boost_python/flex_sort.cpp
      array_family/boost_python/flex_histogram.cpp
      array_family/boost_python/flex_weighted_histogram.cpp
      array_family/boost_python/flex_mean_and_variance.cpp
      array_family/boost_python/flex_median.cpp
      array_family/boost_python/flex_linear_interpolation.cpp
      array_family/boost_python/flex_vec3_double.cpp
      array_family/boost_python/flex_vec2_double.cpp
      array_family/boost_python/flex_vec3_int.cpp
      array_family/boost_python/flex_sym_mat3_double.cpp
      array_family/boost_python/flex_mat3_double.cpp
      array_family/boost_python/flex_tiny_size_t_2.cpp
      array_family/boost_python/loops.cpp
      array_family/boost_python/show_sizes.cpp
      array_family/boost_python/numpy_bridge.cpp
    LIBRARIES scitbx_boost_python
  )
  target_compile_definitions(scitbx_array_family_flex_ext PRIVATE
    SCITBX_HAVE_NUMPY_INCLUDE
  )

  cctbx_add_python_extension(scitbx_cubicle_neighbors_ext
    SOURCES cubicle_neighbors_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_fftpack_ext
    SOURCES fftpack/boost_python/fftpack_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_math_ext
    SOURCES
      math/boost_python/math_ext.cpp
      math/boost_python/basic_statistics.cpp
      math/boost_python/gaussian.cpp
      math/boost_python/golay.cpp
      math/boost_python/minimum_covering_sphere.cpp
      math/boost_python/principal_axes_of_inertia.cpp
      math/boost_python/row_echelon.cpp
      math/boost_python/tensor_rank_2.cpp
      math/boost_python/chebyshev.cpp
      math/boost_python/icosahedron.cpp
      math/boost_python/slatec.cpp
      math/boost_python/line_search.cpp
      math/boost_python/r3_rotation.cpp
      math/boost_python/resample.cpp
      math/boost_python/quadrature.cpp
      math/boost_python/unimodular_generator.cpp
      math/boost_python/halton.cpp
      math/boost_python/least_squares_plane.cpp
      math/boost_python/continued_fraction.cpp
      math/boost_python/numeric_limits.cpp
      math/boost_python/distributions.cpp
      math/boost_python/exp_functions.cpp
      math/boost_python/zernike.cpp
      math/boost_python/zernike_moments.cpp
      math/boost_python/2d_zernike_moments.cpp
      math/boost_python/weighted_covariance.cpp
      math/boost_python/rotation.cpp
      math/boost_python/interpolation.cpp
      math/boost_python/tetrahedron.cpp
      math/boost_python/angle_derivative.cpp
    LIBRARIES scitbx_slatec scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_random_ext
    SOURCES
      random/boost_python/random_ext.cpp
      random/boost_python/basic_distributions.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_sparse_ext
    SOURCES
      sparse/boost_python/vector.cpp
      sparse/boost_python/matrix.cpp
      sparse/boost_python/approx_equal.cpp
      sparse/boost_python/random.cpp
      sparse/boost_python/lu_factorization.cpp
      sparse/boost_python/sparse_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_lbfgs_ext
    SOURCES lbfgs/ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_lbfgsb_ext
    SOURCES lbfgsb/boost_python/lbfgsb_ext.cpp
    LIBRARIES scitbx_boost_python Boost::timer Boost::chrono
  )

  cctbx_add_python_extension(scitbx_lstbx_normal_equations_ext
    SOURCES
      lstbx/boost_python/lstbx_ext.cpp
      lstbx/boost_python/normal_equations.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_minpack_ext
    SOURCES minpack/ext.cpp
    LIBRARIES scitbx_minpack scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_r3_utils_ext
    SOURCES r3_utils_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_iso_surface_ext
    SOURCES iso_surface/iso_surface_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_rigid_body_ext
    SOURCES rigid_body/ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_wigner_ext
    SOURCES wigner/ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_graphics_utils_ext
    SOURCES graphics_utils/ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_suffixtree_shared_ext
    SOURCES suffixtree/boost_python/suffixtree_shared_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_suffixtree_single_ext
    SOURCES
      suffixtree/boost_python/suffixtree_single_ext.cpp
      suffixtree/boost_python/object_extensions.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(scitbx_examples_bevington_ext
    SOURCES examples/bevington/bevington_ext.cpp
    LIBRARIES cctbx_core scitbx_boost_python Eigen3::Eigen
  )

  cctbx_add_python_extension(scitbx_glmtbx_ext
    SOURCES glmtbx/boost_python/ext.cc
    LIBRARIES scitbx_boost_python
  )
endif()
