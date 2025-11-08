# cctbx (Computational Crystallography Toolbox) module

# Include directories - need parent of cctbx for <cctbx/...> and <scitbx/...> includes to work
include_directories(
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# Build libcctbx library
set(CCTBX_LIB_SOURCES
    eltbx/basic.cpp
    eltbx/xray_scattering/it1992.cpp
    eltbx/xray_scattering/wk1995.cpp
    eltbx/xray_scattering/n_gaussian_raw.cpp
    eltbx/xray_scattering/n_gaussian.cpp
    eltbx/fp_fdp.cpp
    # henke.cpp is generated, use table files instead
    eltbx/henke_tables_01_12.cpp
    eltbx/henke_tables_13_24.cpp
    eltbx/henke_tables_25_36.cpp
    eltbx/henke_tables_37_48.cpp
    eltbx/henke_tables_49_60.cpp
    eltbx/henke_tables_61_72.cpp
    eltbx/henke_tables_73_84.cpp
    eltbx/henke_tables_85_92.cpp
    eltbx/icsd_radii.cpp
    eltbx/covalent_radii.cpp
    eltbx/neutron.cpp
    eltbx/sasaki.cpp
    eltbx/sasaki_tables_01_12.cpp
    eltbx/sasaki_tables_13_24.cpp
    eltbx/sasaki_tables_25_36.cpp
    eltbx/sasaki_tables_37_48.cpp
    eltbx/sasaki_tables_49_60.cpp
    eltbx/sasaki_tables_61_72.cpp
    eltbx/sasaki_tables_73_82.cpp
    eltbx/tiny_pse.cpp
    eltbx/wavelengths.cpp
    eltbx/electron_scattering/peng1996.cpp
    eltbx/attenuation_coefficient.cpp
    miller/asu.cpp
    miller/bins.cpp
    miller/index_generator.cpp
    miller/index_span.cpp
    miller/match_bijvoet_mates.cpp
    miller/match_indices.cpp
    miller/match_multi_indices.cpp
    miller/sym_equiv.cpp
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

# Filter out sources that don't exist
set(CCTBX_LIB_SOURCES_FILTERED)
foreach(src ${CCTBX_LIB_SOURCES})
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
        list(APPEND CCTBX_LIB_SOURCES_FILTERED ${src})
    endif()
endforeach()

if(CCTBX_LIB_SOURCES_FILTERED)
    add_library(cctbx SHARED ${CCTBX_LIB_SOURCES_FILTERED})
    target_link_libraries(cctbx
        ${Boost_LIBRARIES}
        m
    )
    set_target_properties(cctbx PROPERTIES
        OUTPUT_NAME "cctbx"
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )
endif()

# Build libcctbx_sgtbx_asu library
file(GLOB CCTBX_SGTBX_ASU_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/sgtbx/direct_space_asu/*.cpp")
list(FILTER CCTBX_SGTBX_ASU_SOURCES EXCLUDE REGEX ".*_ext\\.cpp$")
if(CCTBX_SGTBX_ASU_SOURCES)
    add_library(cctbx_sgtbx_asu SHARED ${CCTBX_SGTBX_ASU_SOURCES})
    target_link_libraries(cctbx_sgtbx_asu cctbx)
    set_target_properties(cctbx_sgtbx_asu PROPERTIES
        OUTPUT_NAME "cctbx_sgtbx_asu"
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )
endif()

# Build libasymmetric_map library
set(ASYMMETRIC_MAP_SOURCES
    maptbx/asymmetric_map.cpp
)
# Add C++11 dependent sources if available
if(CMAKE_CXX_STANDARD GREATER_EQUAL 11)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/maptbx/skeletons.cpp")
        list(APPEND ASYMMETRIC_MAP_SOURCES maptbx/skeletons.cpp)
    endif()
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/maptbx/dijkstra.cpp")
        list(APPEND ASYMMETRIC_MAP_SOURCES maptbx/dijkstra.cpp)
    endif()
endif()
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/maptbx/asymmetric_map.cpp")
    add_library(asymmetric_map SHARED ${ASYMMETRIC_MAP_SOURCES})
    target_link_libraries(asymmetric_map cctbx)
    if(TARGET cctbx_sgtbx_asu)
        target_link_libraries(asymmetric_map cctbx_sgtbx_asu)
    endif()
    if(TARGET iotbx_xplor)
        target_link_libraries(asymmetric_map iotbx_xplor)
    endif()
    if(TARGET omptbx)
        target_link_libraries(asymmetric_map omptbx)
    endif()
    set_target_properties(asymmetric_map PROPERTIES
        OUTPUT_NAME "asymmetric_map"
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )
endif()

# Auto-detect and build all *_ext.cpp files as Python extension modules
file(GLOB_RECURSE CCTBX_ALL_EXT_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*_ext.cpp")

foreach(ext_source ${CCTBX_ALL_EXT_SOURCES})
    # Get the relative path and create module name
    file(RELATIVE_PATH rel_path ${CMAKE_CURRENT_SOURCE_DIR} ${ext_source})
    string(REPLACE "/" "_" module_name "${rel_path}")
    string(REPLACE ".cpp" "" module_name "${module_name}")
    string(PREPEND module_name "cctbx_")

    # Skip proto/test extensions
    if(NOT rel_path MATCHES "proto/")
        add_python_module(${module_name}
            SOURCES ${ext_source}
        )
    endif()
endforeach()

message(STATUS "Added module: cctbx")
