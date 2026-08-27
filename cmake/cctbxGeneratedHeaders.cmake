# Source-generator templates copied verbatim into the build tree.
set(CCTBX_GENERATED_INCLUDE_DIR "${PROJECT_BINARY_DIR}/include")
set(CCTBX_GENERATED_ARRAY_FAMILY_DIR
  "${CCTBX_GENERATED_INCLUDE_DIR}/scitbx/array_family")
set(CCTBX_GENERATED_ARRAY_FAMILY_STAMP
  "${CCTBX_GENERATED_ARRAY_FAMILY_DIR}/.generated")
set(CCTBX_GENERATED_CCTBX_FLEX_FWD
  "${CCTBX_GENERATED_INCLUDE_DIR}/cctbx/boost_python/flex_fwd.h")
set(CCTBX_GENERATED_SCITBX_FLEX_FWD
  "${CCTBX_GENERATED_INCLUDE_DIR}/scitbx/array_family/boost_python/flex_fwd.h")
set(CCTBX_GENERATED_SMTBX_FLEX_FWD
  "${CCTBX_GENERATED_INCLUDE_DIR}/smtbx/boost_python/flex_fwd.h")
set(CCTBX_GENERATED_TYPE_ID_EQ
  "${CCTBX_GENERATED_INCLUDE_DIR}/boost_adaptbx/type_id_eq.h")

foreach(_dir
    cctbx/boost_python
    scitbx/array_family/boost_python
    smtbx/boost_python
    boost_adaptbx)
  file(MAKE_DIRECTORY "${CCTBX_GENERATED_INCLUDE_DIR}/${_dir}")
endforeach()

configure_file(
  "${CMAKE_CURRENT_LIST_DIR}/cctbx_flex_fwd.h.in"
  "${CCTBX_GENERATED_CCTBX_FLEX_FWD}"
  COPYONLY
)
configure_file(
  "${CMAKE_CURRENT_LIST_DIR}/scitbx_flex_fwd.h.in"
  "${CCTBX_GENERATED_SCITBX_FLEX_FWD}"
  COPYONLY
)
configure_file(
  "${CMAKE_CURRENT_LIST_DIR}/smtbx_flex_fwd.h.in"
  "${CCTBX_GENERATED_SMTBX_FLEX_FWD}"
  COPYONLY
)
configure_file(
  "${CMAKE_CURRENT_LIST_DIR}/type_id_eq.h.in"
  "${CCTBX_GENERATED_TYPE_ID_EQ}"
  COPYONLY
)

add_custom_command(
  OUTPUT "${CCTBX_GENERATED_ARRAY_FAMILY_STAMP}"
  COMMAND ${CMAKE_COMMAND} -E make_directory
    "${CCTBX_GENERATED_ARRAY_FAMILY_DIR}/detail"
  COMMAND ${CMAKE_COMMAND} -E env
    "PYTHONPATH=${PROJECT_SOURCE_DIR}:$ENV{PYTHONPATH}"
    "${Python3_EXECUTABLE}" -c
    "from scitbx.source_generators.array_family import generate_all; generate_all.refresh(r'${CCTBX_GENERATED_ARRAY_FAMILY_DIR}')"
  COMMAND ${CMAKE_COMMAND} -E touch "${CCTBX_GENERATED_ARRAY_FAMILY_STAMP}"
  DEPENDS
    scitbx/source_generators/array_family/generate_all.py
    scitbx/source_generators/array_family/generate_reductions.py
    scitbx/source_generators/array_family/generate_operator_traits_builtin.py
  WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
  VERBATIM
)

add_custom_target(cctbx_generated_headers
  DEPENDS
    "${CCTBX_GENERATED_ARRAY_FAMILY_STAMP}"
    "${CCTBX_GENERATED_CCTBX_FLEX_FWD}"
    "${CCTBX_GENERATED_SCITBX_FLEX_FWD}"
    "${CCTBX_GENERATED_SMTBX_FLEX_FWD}"
    "${CCTBX_GENERATED_TYPE_ID_EQ}")
