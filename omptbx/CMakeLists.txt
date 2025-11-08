# omptbx - OpenMP toolbox
project(omptbx)

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# Build libomptbx library
file(GLOB OMPTBX_LIB_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
list(FILTER OMPTBX_LIB_SOURCES EXCLUDE REGEX ".*_ext\\.cpp$")
if(OMPTBX_LIB_SOURCES)
    add_library(omptbx SHARED ${OMPTBX_LIB_SOURCES})
    if(OpenMP_CXX_FOUND)
        target_link_libraries(omptbx OpenMP::OpenMP_CXX)
    endif()
    set_target_properties(omptbx PROPERTIES
        OUTPUT_NAME "omptbx"
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )
endif()

# Auto-detect and build all *_ext.cpp files as Python extension modules
file(GLOB OMPTBX_ALL_EXT_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*_ext.cpp")

foreach(ext_source ${OMPTBX_ALL_EXT_SOURCES})
    get_filename_component(module_name ${ext_source} NAME_WE)
    add_python_module(${module_name}
        SOURCES ${ext_source}
    )
endforeach()

message(STATUS "Added module: omptbx")
