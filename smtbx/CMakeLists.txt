# smtbx - Small molecule crystallography toolbox
project(smtbx)

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# Build libsmtbx_refinement_constraints library
file(GLOB SMTBX_REFINEMENT_CONSTRAINTS_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/refinement/constraints/*.cpp"
)
list(FILTER SMTBX_REFINEMENT_CONSTRAINTS_SOURCES EXCLUDE REGEX ".*_ext\\.cpp$")
if(SMTBX_REFINEMENT_CONSTRAINTS_SOURCES)
    add_library(smtbx_refinement_constraints SHARED ${SMTBX_REFINEMENT_CONSTRAINTS_SOURCES})
    target_link_libraries(smtbx_refinement_constraints cctbx)
    set_target_properties(smtbx_refinement_constraints PROPERTIES
        OUTPUT_NAME "smtbx_refinement_constraints"
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )
endif()

# Auto-detect and build all *_ext.cpp files as Python extension modules
file(GLOB_RECURSE SMTBX_ALL_EXT_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*_ext.cpp")

foreach(ext_source ${SMTBX_ALL_EXT_SOURCES})
    # Get the relative path and create module name
    file(RELATIVE_PATH rel_path ${CMAKE_CURRENT_SOURCE_DIR} ${ext_source})
    string(REPLACE "/" "_" module_name "${rel_path}")
    string(REPLACE ".cpp" "" module_name "${module_name}")
    string(PREPEND module_name "smtbx_")

    add_python_module(${module_name}
        SOURCES ${ext_source}
    )
endforeach()

message(STATUS "Added module: smtbx")
