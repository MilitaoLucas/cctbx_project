# iotbx - I/O toolbox for crystallographic file formats
project(iotbx)

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# Build libiotbx_pdb library
file(GLOB IOTBX_PDB_LIB_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/pdb/*.cpp")
list(FILTER IOTBX_PDB_LIB_SOURCES EXCLUDE REGEX ".*_ext\\.cpp$")
if(IOTBX_PDB_LIB_SOURCES)
    add_library(iotbx_pdb SHARED ${IOTBX_PDB_LIB_SOURCES})
    target_link_libraries(iotbx_pdb cctbx)
    set_target_properties(iotbx_pdb PROPERTIES
        OUTPUT_NAME "iotbx_pdb"
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )
endif()

# Build libiotbx_xplor library
file(GLOB IOTBX_XPLOR_LIB_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/xplor/*.cpp")
list(FILTER IOTBX_XPLOR_LIB_SOURCES EXCLUDE REGEX ".*_ext\\.cpp$")
if(IOTBX_XPLOR_LIB_SOURCES)
    add_library(iotbx_xplor SHARED ${IOTBX_XPLOR_LIB_SOURCES})
    target_link_libraries(iotbx_xplor cctbx)
    set_target_properties(iotbx_xplor PROPERTIES
        OUTPUT_NAME "iotbx_xplor"
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )
endif()

# Build libiotbx_mtz library (requires ccp4io)
file(GLOB IOTBX_MTZ_LIB_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/mtz/*.cpp")
list(FILTER IOTBX_MTZ_LIB_SOURCES EXCLUDE REGEX ".*_ext\\.cpp$")
if(IOTBX_MTZ_LIB_SOURCES)
    add_library(iotbx_mtz SHARED ${IOTBX_MTZ_LIB_SOURCES})
    target_link_libraries(iotbx_mtz cctbx)
    set_target_properties(iotbx_mtz PROPERTIES
        OUTPUT_NAME "iotbx_mtz"
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )
endif()

# Auto-detect and build all *_ext.cpp files as Python extension modules
file(GLOB_RECURSE IOTBX_ALL_EXT_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*_ext.cpp")

foreach(ext_source ${IOTBX_ALL_EXT_SOURCES})
    # Get the relative path and create module name
    file(RELATIVE_PATH rel_path ${CMAKE_CURRENT_SOURCE_DIR} ${ext_source})
    string(REPLACE "/" "_" module_name "${rel_path}")
    string(REPLACE ".cpp" "" module_name "${module_name}")
    string(PREPEND module_name "iotbx_")

    add_python_module(${module_name}
        SOURCES ${ext_source}
    )
endforeach()

message(STATUS "Added module: iotbx")
