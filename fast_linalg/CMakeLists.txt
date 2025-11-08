# fast_linalg - Fast linear algebra routines
project(fast_linalg)

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# Build libfast_linalg library
file(GLOB FAST_LINALG_LIB_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
list(FILTER FAST_LINALG_LIB_SOURCES EXCLUDE REGEX ".*_ext\\.cpp$")
if(FAST_LINALG_LIB_SOURCES)
    add_library(fast_linalg SHARED ${FAST_LINALG_LIB_SOURCES})
    target_link_libraries(fast_linalg cctbx)
    set_target_properties(fast_linalg PROPERTIES
        OUTPUT_NAME "fast_linalg"
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )
endif()

# Auto-detect and build all *_ext.cpp files as Python extension modules
file(GLOB_RECURSE FAST_LINALG_ALL_EXT_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*_ext.cpp")

foreach(ext_source ${FAST_LINALG_ALL_EXT_SOURCES})
    get_filename_component(module_name ${ext_source} NAME_WE)
    add_python_module(${module_name}
        SOURCES ${ext_source}
    )
endforeach()

message(STATUS "Added module: fast_linalg")
