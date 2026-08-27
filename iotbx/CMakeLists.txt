add_library(iotbx_xplor SHARED
  xplor/map_reader.cpp
  xplor/map_writer.cpp
)
target_link_libraries(iotbx_xplor PUBLIC cctbx_build_options m)
set_target_properties(iotbx_xplor PROPERTIES OUTPUT_NAME iotbx_xplor)

add_library(iotbx_pdb SHARED
  pdb/hybrid_36_c.c
  pdb/hybrid_36_cpp.cpp
  pdb/utils.cpp
  pdb/write_utils.cpp
  pdb/hierarchy.cpp
  pdb/hierarchy_select.cpp
  pdb/hierarchy_atoms.cpp
  pdb/construct_hierarchy.cpp
  pdb/overall_counts.cpp
  pdb/hierarchy_write.cpp
  pdb/atom_selection.cpp
  pdb/input.cpp
  pdb/input_write.cpp
)
target_link_libraries(iotbx_pdb PUBLIC cctbx_build_options)
set_target_properties(iotbx_pdb PROPERTIES OUTPUT_NAME iotbx_pdb)

install(TARGETS iotbx_xplor iotbx_pdb
  EXPORT cctbxTargets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

if(CCTBX_BUILD_PYTHON)
  cctbx_add_python_extension(iotbx_detectors_ext
    SOURCES
      detectors/detectors_ext.cpp
      detectors/image_divider.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(iotbx_detectors_bruker_ext
    SOURCES
      detectors/bruker_ext.cpp
      detectors/bruker.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(iotbx_dsn6_map_ext
    SOURCES dsn6/ext.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )

  cctbx_add_python_extension(iotbx_pdb_ext
    SOURCES
      pdb/ext.cpp
      pdb/hybrid_36_bpl.cpp
      pdb/common_residue_names_bpl.cpp
      pdb/rna_dna_atom_names_bpl.cpp
      pdb/input_bpl.cpp
      pdb/xray_structure_bpl.cpp
    LIBRARIES iotbx_pdb cctbx_core scitbx_boost_python
  )
  target_include_directories(iotbx_pdb_ext PRIVATE
    ${PROJECT_SOURCE_DIR}/fable
  )

  cctbx_add_python_extension(iotbx_pdb_hierarchy_ext
    SOURCES
      pdb/hierarchy_ext.cpp
      pdb/hierarchy_atom_bpl.cpp
      pdb/hierarchy_atoms_bpl.cpp
    LIBRARIES iotbx_pdb cctbx_core scitbx_boost_python
  )

  cctbx_add_python_extension(iotbx_shelx_ext
    SOURCES shelx/shelx_ext.cpp
    LIBRARIES scitbx_boost_python
  )
  target_include_directories(iotbx_shelx_ext PRIVATE
    ${PROJECT_SOURCE_DIR}/fable
  )

  cctbx_add_python_extension(iotbx_wildcard_ext
    SOURCES wildcard_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(iotbx_dtrek_ext
    SOURCES misc/boost_python/dtrek_ext.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )

  cctbx_add_python_extension(iotbx_scalepack_ext
    SOURCES misc/boost_python/scalepack_ext.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )

  set(UCIF_ANTLR3_SOURCES
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3baserecognizer.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3basetree.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3basetreeadaptor.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3bitset.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3collections.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3commontoken.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3commontree.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3commontreeadaptor.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3commontreenodestream.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3convertutf.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3cyclicdfa.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3debughandlers.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3encodings.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3exception.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3filestream.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3inputstream.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3intstream.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3lexer.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3parser.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3rewritestreams.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3string.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3tokenstream.c
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/src/antlr3treeparser.c
  )

  cctbx_add_python_extension(iotbx_cif_ext
    SOURCES
      cif/boost_python/cif_ext.cpp
      ${PROJECT_SOURCE_DIR}/ucif/cifLexer.cpp
      ${PROJECT_SOURCE_DIR}/ucif/cifParser.cpp
      ${UCIF_ANTLR3_SOURCES}
    LIBRARIES scitbx_boost_python
  )
  target_include_directories(iotbx_cif_ext PRIVATE
    ${PROJECT_SOURCE_DIR}/ucif/antlr3
    ${PROJECT_SOURCE_DIR}/ucif/antlr3/include
    ${PROJECT_SOURCE_DIR}/ucif
  )
  target_compile_definitions(iotbx_cif_ext PRIVATE ANTLR3_NODEBUGGER)

  cctbx_add_python_extension(iotbx_xplor_ext
    SOURCES xplor/boost_python/xplor_ext.cpp
    LIBRARIES iotbx_xplor cctbx_core scitbx_boost_python
  )

  if(CCTBX_USE_CCP4IO)
    add_library(iotbx_mtz SHARED
      mtz/object.cpp
      mtz/crystal.cpp
      mtz/dataset.cpp
      mtz/column.cpp
    )
    target_link_libraries(iotbx_mtz PUBLIC cctbx_build_options ccp4io)
    set_target_properties(iotbx_mtz PROPERTIES OUTPUT_NAME iotbx_mtz)

    cctbx_add_python_extension(iotbx_mtz_ext
      SOURCES
        mtz/ext.cpp
        mtz/object_bpl.cpp
        mtz/crystal_bpl.cpp
        mtz/dataset_bpl.cpp
        mtz/column_bpl.cpp
        mtz/batch_bpl.cpp
      LIBRARIES iotbx_mtz cctbx_core scitbx_boost_python ccp4io
    )

    cctbx_add_python_extension(iotbx_ccp4_map_ext
      SOURCES ccp4_map/ext.cpp
      LIBRARIES cctbx_core scitbx_boost_python ccp4io
    )

    install(TARGETS iotbx_mtz
      EXPORT cctbxTargets
      LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
      ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )
  endif()
endif()
