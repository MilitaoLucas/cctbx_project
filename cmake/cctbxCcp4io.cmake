# Builds the vendored CCP4 / MMDB / SSM sources as a static `ccp4io` library
# (the same approach as nix/ccp4io_adaptbx/CMakeLists.txt) and the
# ccp4io_adaptbx Boost.Python extension.  Requires these variables to be set:
#   CCP4IO_SOURCE_DIR          - root of the fetched ccp4io repository
#   CCP4IO_ADAPTBX_SOURCE_DIR  - root of the fetched ccp4io_adaptbx repository
#   PROJECT_SOURCE_DIR         - the cctbx_project source root
# The library is consumed by iotbx_mtz_ext / iotbx_ccp4_map_ext (iotbx) and by
# ccp4io_adaptbx_ext.

set(_ccp4_ccp4_dir "${CCP4IO_SOURCE_DIR}/libccp4/ccp4")
set(_ccp4_fortran_dir "${CCP4IO_SOURCE_DIR}/libccp4/fortran")
set(_ccp4_mmdb_dir "${CCP4IO_SOURCE_DIR}/mmdb")
set(_ccp4_ssm_dir "${CCP4IO_SOURCE_DIR}/ssm")

# Files that live in the fortran tree but are compiled as C.
set(_ccp4_fortran_c_files
  ${_ccp4_fortran_dir}/ccp4_diskio_f.c
  ${_ccp4_fortran_dir}/ccp4_general_f.c
  ${_ccp4_fortran_dir}/ccp4_parser_f.c
  ${_ccp4_fortran_dir}/ccp4_unitcell_f.c
  ${_ccp4_fortran_dir}/cmaplib_f.c
  ${_ccp4_fortran_dir}/cmtzlib_f.c
  ${_ccp4_fortran_dir}/csymlib_f.c
  ${_ccp4_fortran_dir}/library_f.c
)

set(_ccp4_single_c_files
  ${_ccp4_ccp4_dir}/ccp4_general.c
  ${_ccp4_ccp4_dir}/ccp4_program.c
)

set(_ccp4_c_files
  ${_ccp4_ccp4_dir}/library_err.c
  ${_ccp4_ccp4_dir}/library_file.c
  ${_ccp4_ccp4_dir}/library_utils.c
  ${_ccp4_ccp4_dir}/ccp4_array.c
  ${_ccp4_ccp4_dir}/ccp4_parser.c
  ${_ccp4_ccp4_dir}/ccp4_unitcell.c
  ${_ccp4_ccp4_dir}/cvecmat.c
  ${_ccp4_ccp4_dir}/cmtzlib.c
  ${_ccp4_ccp4_dir}/cmap_accessor.c
  ${_ccp4_ccp4_dir}/cmap_close.c
  ${_ccp4_ccp4_dir}/cmap_data.c
  ${_ccp4_ccp4_dir}/cmap_header.c
  ${_ccp4_ccp4_dir}/cmap_labels.c
  ${_ccp4_ccp4_dir}/cmap_open.c
  ${_ccp4_ccp4_dir}/cmap_skew.c
  ${_ccp4_ccp4_dir}/cmap_stats.c
  ${_ccp4_ccp4_dir}/cmap_symop.c
  ${_ccp4_ccp4_dir}/csymlib.c
  ${_ccp4_ccp4_dir}/ccp4_general.c
  ${_ccp4_ccp4_dir}/ccp4_program.c
)

set(_ccp4_mmdb_files
  ${_ccp4_mmdb_dir}/hybrid_36.cpp
  ${_ccp4_mmdb_dir}/mmdb_atom.cpp
  ${_ccp4_mmdb_dir}/mmdb_bondmngr.cpp
  ${_ccp4_mmdb_dir}/mmdb_chain.cpp
  ${_ccp4_mmdb_dir}/mmdb_cifdefs.cpp
  ${_ccp4_mmdb_dir}/mmdb_coormngr.cpp
  ${_ccp4_mmdb_dir}/mmdb_cryst.cpp
  ${_ccp4_mmdb_dir}/mmdb_ficif.cpp
  ${_ccp4_mmdb_dir}/mmdb_io_file.cpp
  ${_ccp4_mmdb_dir}/mmdb_io_stream.cpp
  ${_ccp4_mmdb_dir}/mmdb_machine_.cpp
  ${_ccp4_mmdb_dir}/mmdb_manager.cpp
  ${_ccp4_mmdb_dir}/mmdb_mask.cpp
  ${_ccp4_mmdb_dir}/mmdb_math_align.cpp
  ${_ccp4_mmdb_dir}/mmdb_math_bfgsmin.cpp
  ${_ccp4_mmdb_dir}/mmdb_math_.cpp
  ${_ccp4_mmdb_dir}/mmdb_math_fft.cpp
  ${_ccp4_mmdb_dir}/mmdb_math_graph.cpp
  ${_ccp4_mmdb_dir}/mmdb_math_linalg.cpp
  ${_ccp4_mmdb_dir}/mmdb_math_rand.cpp
  ${_ccp4_mmdb_dir}/mmdb_mattype.cpp
  ${_ccp4_mmdb_dir}/mmdb_mmcif_.cpp
  ${_ccp4_mmdb_dir}/mmdb_model.cpp
  ${_ccp4_mmdb_dir}/mmdb_root.cpp
  ${_ccp4_mmdb_dir}/mmdb_rwbrook.cpp
  ${_ccp4_mmdb_dir}/mmdb_selmngr.cpp
  ${_ccp4_mmdb_dir}/mmdb_seqsuperpose.cpp
  ${_ccp4_mmdb_dir}/mmdb_symop.cpp
  ${_ccp4_mmdb_dir}/mmdb_tables.cpp
  ${_ccp4_mmdb_dir}/mmdb_title.cpp
  ${_ccp4_mmdb_dir}/mmdb_uddata.cpp
  ${_ccp4_mmdb_dir}/mmdb_utils.cpp
  ${_ccp4_mmdb_dir}/mmdb_xml_.cpp
)

set(_ccp4_ssm_files
  ${_ccp4_ssm_dir}/ssm_csia.cpp
  ${_ccp4_ssm_dir}/ssm_graph.cpp
  ${_ccp4_ssm_dir}/ssm_vxedge.cpp
  ${_ccp4_ssm_dir}/ssm_align.cpp
  ${_ccp4_ssm_dir}/ssm_superpose.cpp
  ${_ccp4_ssm_dir}/ssm_malign.cpp
)

add_library(ccp4io STATIC
  ${_ccp4_c_files}
  ${_ccp4_fortran_c_files}
  ${_ccp4_single_c_files}
  ${_ccp4_mmdb_files}
  ${_ccp4_ssm_files}
  ${CCP4IO_ADAPTBX_SOURCE_DIR}/fortran_call_stubs.c
  ${CCP4IO_ADAPTBX_SOURCE_DIR}/printf_wrappers.c
)
target_include_directories(ccp4io PUBLIC
  $<BUILD_INTERFACE:${CCP4IO_SOURCE_DIR}>
  $<BUILD_INTERFACE:${_ccp4_ccp4_dir}>
  $<BUILD_INTERFACE:${_ccp4_fortran_dir}>
  $<BUILD_INTERFACE:${_ccp4_mmdb_dir}>
  $<BUILD_INTERFACE:${_ccp4_ssm_dir}>
  $<BUILD_INTERFACE:${CCP4IO_ADAPTBX_SOURCE_DIR}/..>
)
target_compile_definitions(ccp4io PUBLIC
  MSETS=32
  MXTALS=32
  MCOLUMNS=128
  USE_CALL_LIKE_SUN
)
# The vendored CCP4 code is old and relies on K&R-style unprototyped
# declarations; build it as C90 with GNU extensions and relax the warnings that
# trip modern compilers.
set_target_properties(ccp4io PROPERTIES
  C_STANDARD 90
  C_STANDARD_REQUIRED ON
  C_EXTENSIONS ON
)
target_compile_options(ccp4io PRIVATE
  -D_DEFAULT_SOURCE
  -Wno-error
  -Wno-format-overflow
  -Wno-format-security
  -Wno-implicit-function-declaration
  -Wno-incompatible-pointer-types
)
target_link_libraries(ccp4io PUBLIC m Threads::Threads)

install(TARGETS ccp4io
  EXPORT cctbxTargets
  ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
)

if(CCTBX_BUILD_PYTHON)
  Python3_add_library(ccp4io_adaptbx_ext MODULE
    ${CCP4IO_ADAPTBX_SOURCE_DIR}/ext.cpp
    WITH_SOABI
  )
  target_link_libraries(ccp4io_adaptbx_ext PRIVATE
    ccp4io
    Python3::Module
    Boost::${_boost_python_component}
    ${CMAKE_DL_LIBS}
  )
  target_include_directories(ccp4io_adaptbx_ext PRIVATE
    ${CCP4IO_ADAPTBX_SOURCE_DIR}
    ${CCP4IO_SOURCE_DIR}
    ${_ccp4_ccp4_dir}
    ${_ccp4_mmdb_dir}
    ${_ccp4_ssm_dir}
    ${PROJECT_SOURCE_DIR}
  )
  add_dependencies(ccp4io_adaptbx_ext cctbx_generated_headers)
  if(CCTBX_WHEEL)
    set_target_properties(ccp4io_adaptbx_ext PROPERTIES
      INSTALL_RPATH "$ORIGIN:$ORIGIN/lib"
    )
  endif()
  set_target_properties(ccp4io_adaptbx_ext PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/python"
  )
  install(TARGETS ccp4io_adaptbx_ext
    LIBRARY DESTINATION "${CCTBX_PYTHON_INSTALL_DIR}"
  )
  # The wrapper looks up the CCP4 data files via libtbx.env.under_dist("ccp4io").
  # ccp4io is not registered as a libtbx module in the unified wheel, so that
  # lookup returns None; guard it so the module still imports.
  set(_ccp4io_init "${CCP4IO_ADAPTBX_SOURCE_DIR}/__init__.py")
  file(READ "${_ccp4io_init}" _ccp4io_init_content)
  string(REPLACE "if (op.isfile(_)):" "if (_ is not None and op.isfile(_)):" _ccp4io_init_content "${_ccp4io_init_content}")
  file(WRITE "${_ccp4io_init}" "${_ccp4io_init_content}")
  install(FILES "${_ccp4io_init}"
    DESTINATION "${CCTBX_PYTHON_INSTALL_DIR}/ccp4io_adaptbx"
  )
endif()
