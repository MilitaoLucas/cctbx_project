if(CCTBX_BUILD_PYTHON AND CCTBX_BUILD_SMTBX)
  add_library(smtbx_refinement_constraints SHARED
    refinement/constraints/affine.cpp
    refinement/constraints/geometrical_hydrogens.cpp
    refinement/constraints/occupancy.cpp
    refinement/constraints/reparametrisation.cpp
    refinement/constraints/rigid.cpp
    refinement/constraints/same_group.cpp
    refinement/constraints/scaled_adp.cpp
    refinement/constraints/shared.cpp
    refinement/constraints/special_position.cpp
    refinement/constraints/symmetry_equivalent.cpp
    refinement/constraints/u_eq_dependent_u_iso.cpp
    refinement/constraints/u_iso_dependent_u_iso.cpp
  )
  target_link_libraries(smtbx_refinement_constraints PUBLIC
    cctbx_core
    scitbx_boost_python
    cctbx_build_options
  )
  target_include_directories(smtbx_refinement_constraints PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
  )
  set_target_properties(smtbx_refinement_constraints PROPERTIES
    OUTPUT_NAME smtbx_refinement_constraints
  )

  add_library(smtbx_ed_data SHARED ED/dyn_calculator.cpp)
  target_link_libraries(smtbx_ed_data PUBLIC
    cctbx_core
    scitbx_boost_python
    cctbx_build_options
  )
  target_include_directories(smtbx_ed_data PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
  )
  set_target_properties(smtbx_ed_data PROPERTIES OUTPUT_NAME smtbx_ed_data)

  cctbx_add_python_extension(smtbx_array_family_ext
    SOURCES array_family/af_ext.cpp
    LIBRARIES scitbx_boost_python cctbx_core
  )

  cctbx_add_python_extension(smtbx_stl_map_ext
    SOURCES stl/map_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(smtbx_refinement_constraints_ext
    SOURCES
      refinement/constraints/boost_python/constraints_ext.cpp
      refinement/constraints/boost_python/affine.cpp
      refinement/constraints/boost_python/direction.cpp
      refinement/constraints/boost_python/geometrical_hydrogens.cpp
      refinement/constraints/boost_python/independent_scalar_parameters.cpp
      refinement/constraints/boost_python/occupancy.cpp
      refinement/constraints/boost_python/reparametrisation.cpp
      refinement/constraints/boost_python/rigid.cpp
      refinement/constraints/boost_python/same_group.cpp
      refinement/constraints/boost_python/scaled_adp.cpp
      refinement/constraints/boost_python/scatterer_parameters.cpp
      refinement/constraints/boost_python/shared.cpp
      refinement/constraints/boost_python/special_position.cpp
      refinement/constraints/boost_python/symmetry_equivalent.cpp
      refinement/constraints/boost_python/u_eq_dependent_u_iso.cpp
      refinement/constraints/boost_python/u_iso_dependent_u_iso.cpp
    LIBRARIES smtbx_refinement_constraints scitbx_boost_python
  )

  cctbx_add_python_extension(smtbx_refinement_restraints_ext
    SOURCES
      refinement/restraints/boost_python/restraints_ext.cpp
      refinement/restraints/boost_python/origin_fixing.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )

  cctbx_add_python_extension(smtbx_ed_data_ext
    SOURCES ED/boost_python/ed_data.cpp
    LIBRARIES smtbx_ed_data scitbx_boost_python
  )

  cctbx_add_python_extension(smtbx_refinement_least_squares_ext
    SOURCES
      refinement/boost_python/least_squares_ext.cpp
      refinement/boost_python/least_squares.cpp
      refinement/boost_python/weighting_schemes.cpp
    LIBRARIES
      smtbx_refinement_constraints
      smtbx_ed_data
      scitbx_boost_python
      Boost::thread
      Boost::chrono
  )

  cctbx_add_python_extension(smtbx_structure_factors_direct_ext
    SOURCES
      structure_factors/direct/boost_python/ext.cpp
      structure_factors/direct/boost_python/standard_xray.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )

  cctbx_add_python_extension(smtbx_ab_initio_ext
    SOURCES ab_initio/ab_initio_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  install(TARGETS smtbx_refinement_constraints smtbx_ed_data
    EXPORT cctbxTargets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )
endif()
