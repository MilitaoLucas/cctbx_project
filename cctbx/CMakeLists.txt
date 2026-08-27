set(CCTBX_CORE_SOURCES
  eltbx/basic.cpp
  eltbx/xray_scattering/it1992.cpp
  eltbx/xray_scattering/wk1995.cpp
  eltbx/xray_scattering/n_gaussian_raw.cpp
  eltbx/xray_scattering/n_gaussian.cpp
  eltbx/fp_fdp.cpp
  eltbx/icsd_radii.cpp
  eltbx/covalent_radii.cpp
  eltbx/neutron.cpp
  eltbx/tiny_pse.cpp
  eltbx/wavelengths.cpp
  eltbx/electron_scattering/peng1996.cpp
  eltbx/attenuation_coefficient.cpp
  eltbx/sasaki_fallback.cpp
  miller/asu.cpp
  miller/bins.cpp
  miller/index_generator.cpp
  miller/index_span.cpp
  miller/match_bijvoet_mates.cpp
  miller/match_indices.cpp
  miller/match_multi_indices.cpp
  miller/sym_equiv.cpp
  sgtbx/direct_space_asu/proto/direct_space_asu.cpp
  sgtbx/direct_space_asu/proto/reference_table.cpp
  sgtbx/direct_space_asu/proto/cut.cpp
  sgtbx/bricks.cpp
  sgtbx/change_of_basis_op.cpp
  sgtbx/find_affine.cpp
  sgtbx/group_codes.cpp
  sgtbx/hall_in.cpp
  sgtbx/lattice_tr.cpp
  sgtbx/lattice_symmetry.cpp
  sgtbx/miller.cpp
  sgtbx/reciprocal_space_asu.cpp
  sgtbx/reciprocal_space_ref_asu.cpp
  sgtbx/rot_mx.cpp
  sgtbx/rot_mx_info.cpp
  sgtbx/row_echelon_solve.cpp
  sgtbx/rt_mx.cpp
  sgtbx/select_generators.cpp
  sgtbx/seminvariant.cpp
  sgtbx/site_symmetry.cpp
  sgtbx/space_group.cpp
  sgtbx/space_group_type.cpp
  sgtbx/symbols.cpp
  sgtbx/tensor_rank_2.cpp
  sgtbx/tr_group.cpp
  sgtbx/tr_vec.cpp
  sgtbx/utils.cpp
  sgtbx/wyckoff.cpp
  sgtbx/reference_settings/hall_symbol_table.cpp
  sgtbx/reference_settings/matrix_group_code_table.cpp
  sgtbx/reference_settings/normalizer.cpp
  sgtbx/reference_settings/wyckoff.cpp
  uctbx/uctbx.cpp
  uctbx/spoil_optimization.cpp
  uctbx/crystal_orientation.cpp
)

add_library(cctbx_core SHARED ${CCTBX_CORE_SOURCES})
add_library(cctbx::core ALIAS cctbx_core)
add_dependencies(cctbx_core cctbx_generated_headers)
target_link_libraries(cctbx_core PUBLIC cctbx_build_options scitbx_slatec m)
target_include_directories(cctbx_core PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
)
set_target_properties(cctbx_core PROPERTIES OUTPUT_NAME cctbx)

install(TARGETS cctbx_core
  EXPORT cctbxTargets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

if(CCTBX_BUILD_PYTHON)
  cctbx_add_python_extension(cctbx_array_family_flex_ext
    SOURCES
      array_family/boost_python/flex_ext.cpp
      array_family/boost_python/flex_hendrickson_lattman.cpp
      array_family/boost_python/flex_miller_index.cpp
      array_family/boost_python/flex_xray_scatterer.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )

  cctbx_add_python_extension(cctbx_statistics_ext
    SOURCES boost_python/statistics_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_emma_ext
    SOURCES boost_python/emma_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_orientation_ext
    SOURCES boost_python/orientation_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_french_wilson_ext
    SOURCES boost_python/french_wilson_ext.cpp
    LIBRARIES cctbx_core
  )

  foreach(_eltbx_module
      chemical_elements
      henke
      fp_fdp
      icsd_radii
      neutron
      sasaki
      tiny_pse
      wavelengths
      covalent_radii
      attenuation_coefficient)
    cctbx_add_python_extension(cctbx_eltbx_${_eltbx_module}_ext
      SOURCES eltbx/boost_python/${_eltbx_module}_ext.cpp
      LIBRARIES cctbx_core
    )
  endforeach()

  cctbx_add_python_extension(cctbx_eltbx_xray_scattering_ext
    SOURCES eltbx/boost_python/xray_scattering_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_sgtbx_asu_ext
    SOURCES sgtbx/direct_space_asu/proto/asu_ext.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )

  cctbx_add_python_extension(cctbx_sgtbx_ext
    SOURCES
      sgtbx/boost_python/sgtbx_ext.cpp
      sgtbx/boost_python/brick.cpp
      sgtbx/boost_python/change_of_basis.cpp
      sgtbx/boost_python/find_affine.cpp
      sgtbx/boost_python/lattice_symmetry.cpp
      sgtbx/boost_python/phase_info.cpp
      sgtbx/boost_python/reciprocal_space_asu.cpp
      sgtbx/boost_python/rot_mx.cpp
      sgtbx/boost_python/rt_mx.cpp
      sgtbx/boost_python/search_symmetry.cpp
      sgtbx/boost_python/seminvariant.cpp
      sgtbx/boost_python/site_symmetry.cpp
      sgtbx/boost_python/space_group.cpp
      sgtbx/boost_python/space_group_type.cpp
      sgtbx/boost_python/sym_equiv_sites.cpp
      sgtbx/boost_python/symbols.cpp
      sgtbx/boost_python/tensor_rank_2.cpp
      sgtbx/boost_python/tensors.cpp
      sgtbx/boost_python/tr_vec.cpp
      sgtbx/boost_python/wyckoff.cpp
      sgtbx/boost_python/select_generators.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_anharmonic_ext
    SOURCES adptbx/boost_python/anharmonic_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_adptbx_ext
    SOURCES
      adptbx/boost_python/adptbx_ext.cpp
      adptbx/boost_python/hirshfeld.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_uctbx_ext
    SOURCES
      uctbx/boost_python/uctbx_ext.cpp
      uctbx/boost_python/fast_minimum_reduction.cpp
      uctbx/boost_python/niggli_reduction.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(determine_unit_cell_ext
    SOURCES uctbx/determine_unit_cell/ext.cpp
    LIBRARIES cctbx_core omptbx scitbx_boost_python
  )

  cctbx_add_python_extension(cctbx_merging_ext
    SOURCES merging/ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_multipolar_ext
    SOURCES multipolar/aspherical_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_other_restraints_ext
    SOURCES
      other_restraints/sump_bpl.cpp
      other_restraints/other_restraints_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_adp_restraints_ext
    SOURCES
      adp_restraints/adp_restraints_bpl.cpp
      adp_restraints/adp_restraints_ext.cpp
      adp_restraints/rigid_bond_bpl.cpp
      adp_restraints/rigu_bpl.cpp
      adp_restraints/adp_similarity_bpl.cpp
      adp_restraints/isotropic_adp_bpl.cpp
      adp_restraints/aniso_restraints_bpl.cpp
      adp_restraints/fixed_u_eq_adp_bpl.cpp
      adp_restraints/npd_adp_bpl.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_geometry_restraints_ext
    SOURCES
      geometry_restraints/geometry_restraints_ext.cpp
      geometry_restraints/bond_bpl.cpp
      geometry_restraints/bond_similarity_bpl.cpp
      geometry_restraints/bond_sorted_bpl.cpp
      geometry_restraints/nonbonded_bpl.cpp
      geometry_restraints/nonbonded_sorted_bpl.cpp
      geometry_restraints/angle_bpl.cpp
      geometry_restraints/dihedral_bpl.cpp
      geometry_restraints/chirality_bpl.cpp
      geometry_restraints/planarity_bpl.cpp
      geometry_restraints/parallelity_bpl.cpp
      geometry_restraints/motif_bpl.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_translation_search_ext
    SOURCES
      translation_search/boost_python/translation_search_ext.cpp
      translation_search/boost_python/fast_nv1995.cpp
      translation_search/boost_python/fast_terms.cpp
      translation_search/boost_python/symmetry_flags.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )

  cctbx_add_python_extension(cctbx_miller_ext
    SOURCES
      miller/boost_python/miller_ext.cpp
      miller/boost_python/asu.cpp
      miller/boost_python/amplitude_normalisation.cpp
      miller/boost_python/bins.cpp
      miller/boost_python/change_basis.cpp
      miller/boost_python/expand_to_p1.cpp
      miller/boost_python/f_calc_map.cpp
      miller/boost_python/index_generator.cpp
      miller/boost_python/index_span.cpp
      miller/boost_python/lookup_utils.cpp
      miller/boost_python/match_bijvoet_mates.cpp
      miller/boost_python/match_indices.cpp
      miller/boost_python/match_multi_indices.cpp
      miller/boost_python/merge_equivalents.cpp
      miller/boost_python/phase_integrator.cpp
      miller/boost_python/phase_transfer.cpp
      miller/boost_python/randomize_amplitude_and_phase.cpp
      miller/boost_python/slices.cpp
      miller/boost_python/sym_equiv.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )

  cctbx_add_python_extension(cctbx_asymmetric_map_ext
    SOURCES
      maptbx/asymmetric_map_ext.cpp
      maptbx/asymmetric_map.cpp
      ${PROJECT_SOURCE_DIR}/iotbx/xplor/map_writer.cpp
    LIBRARIES cctbx_core scitbx_boost_python OpenMP::OpenMP_CXX
  )

  cctbx_add_python_extension(cctbx_xray_ext
    SOURCES
      xray/boost_python/xray_ext.cpp
      xray/boost_python/conversions.cpp
      xray/boost_python/gradient_flags.cpp
      xray/boost_python/gradients_direct.cpp
      xray/boost_python/each_hkl_gradients_direct.cpp
      xray/boost_python/fast_gradients.cpp
      xray/boost_python/minimization.cpp
      xray/boost_python/scatterer_flags.cpp
      xray/boost_python/scatterer.cpp
      xray/boost_python/scattering_type_registry.cpp
      xray/boost_python/sampling_base.cpp
      xray/boost_python/sampled_model_density.cpp
      xray/boost_python/structure_factors_direct.cpp
      xray/boost_python/structure_factors_simple.cpp
      xray/boost_python/curvatures_simple.cpp
      xray/boost_python/targets.cpp
      xray/boost_python/f_model_bpl.cpp
      xray/boost_python/twin_targets.cpp
      xray/boost_python/grouped_data.cpp
      xray/boost_python/parameter_map.cpp
      xray/boost_python/twin_components.cpp
      xray/boost_python/thickness.cpp
      xray/boost_python/extinction.cpp
      xray/boost_python/dispersion_radial.cpp
      xray/boost_python/sigmaa.cpp
      xray/targets/shelxl_wght_ls_bpl.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )
  target_include_directories(cctbx_xray_ext PRIVATE
    "${PROJECT_SOURCE_DIR}/fable"
  )

  cctbx_add_python_extension(cctbx_xray_observations_ext
    SOURCES
      xray/observations/boost_python/observations.cpp
      xray/observations/boost_python/observations_ext.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )

  cctbx_add_python_extension(cctbx_maptbx_ext
    SOURCES
      maptbx/boost_python/maptbx_ext.cpp
      maptbx/boost_python/grid_indices_around_sites.cpp
      maptbx/boost_python/grid_tags.cpp
      maptbx/boost_python/gridding.cpp
      maptbx/boost_python/misc.cpp
      maptbx/boost_python/peak_search.cpp
      maptbx/boost_python/pymol_interface.cpp
      maptbx/boost_python/statistics.cpp
      maptbx/boost_python/structure_factors.cpp
      maptbx/boost_python/coordinate_transformers.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_maptbx_bcr_bcr_ext
    SOURCES maptbx/bcr/bcr_ext.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )

  cctbx_add_python_extension(cctbx_masks_ext
    SOURCES masks/boost_python/masks_ext.cpp
    LIBRARIES cctbx_core omptbx scitbx_boost_python
  )

  cctbx_add_python_extension(cctbx_symmetry_search_ext
    SOURCES symmetry_search/boost_python/symmetry_search_ext.cpp
    LIBRARIES cctbx_core omptbx scitbx_boost_python
  )

  cctbx_add_python_extension(cctbx_crystal_ext
    SOURCES
      crystal/crystal_ext.cpp
      crystal/asu_clusters_bpl.cpp
      crystal/close_packing_bpl.cpp
      crystal/coordination_sequences_bpl.cpp
      crystal/direct_space_asu_bpl.cpp
      crystal/incremental_pairs_bpl.cpp
      crystal/neighbors_bpl.cpp
      crystal/pair_tables_bpl.cpp
      crystal/site_cluster_analysis_bpl.cpp
      crystal/symmetry_bpl.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_covariance_ext
    SOURCES covariance/boost_python/covariance_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_geometry_ext
    SOURCES geometry/boost_python/geometry_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_math_ext
    SOURCES math/boost_python/math_ext.cpp
    LIBRARIES cctbx_core
  )

  cctbx_add_python_extension(cctbx_dmtbx_ext
    SOURCES
      dmtbx/boost_python/dmtbx_ext.cpp
      dmtbx/boost_python/triplet_phase_relation.cpp
      dmtbx/boost_python/triplet_generator.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )

  cctbx_add_python_extension(cctbx_large_scale_merging_ext
    SOURCES examples/merging/large_scale_merging_ext.cpp
    LIBRARIES cctbx_core scitbx_boost_python Eigen3::Eigen
  )
endif()
