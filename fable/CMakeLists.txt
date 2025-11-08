# fable - Fortran to C++ converter
project(fable)

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# Auto-detect and build all *_ext.cpp files as Python extension modules
file(GLOB_RECURSE FABLE_ALL_EXT_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*_ext.cpp")

foreach(ext_source ${FABLE_ALL_EXT_SOURCES})
    get_filename_component(module_name ${ext_source} NAME_WE)
    add_python_module(${module_name}
        SOURCES ${ext_source}
    )
endforeach()

message(STATUS "Added module: fable")
