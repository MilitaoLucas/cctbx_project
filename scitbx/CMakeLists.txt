# scitbx (Scientific Toolbox) module

# Include directories - need parent of scitbx for <scitbx/...> includes to work
include_directories(
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# Custom target to generate required source files
add_custom_target(scitbx_generate_sources
    COMMAND ${CMAKE_COMMAND} -E env "PYTHONPATH=${CMAKE_SOURCE_DIR}"
            ${Python3_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/source_generators/run_generate_flex_fwd.py
    COMMAND ${CMAKE_COMMAND} -E env "PYTHONPATH=${CMAKE_SOURCE_DIR}"
            ${Python3_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/source_generators/array_family/run_generate_all.py
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Generating scitbx source files (flex_fwd.h, array_family)"
    VERBATIM
)

# Build libscitbx_boost_python library
file(GLOB SCITBX_BOOST_PYTHON_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/boost_python/*.cpp"
)
if(SCITBX_BOOST_PYTHON_SOURCES)
    add_library(scitbx_boost_python SHARED ${SCITBX_BOOST_PYTHON_SOURCES})
    add_dependencies(scitbx_boost_python scitbx_generate_sources)
    target_link_libraries(scitbx_boost_python
        ${Boost_LIBRARIES}
        ${Python3_LIBRARIES}
    )
    set_target_properties(scitbx_boost_python PROPERTIES
        OUTPUT_NAME "scitbx_boost_python"
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )
endif()

# Build libscitbx_minpack library
file(GLOB SCITBX_MINPACK_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/minpack/*.cpp")
list(FILTER SCITBX_MINPACK_SOURCES EXCLUDE REGEX ".*_ext\\.cpp$")
if(SCITBX_MINPACK_SOURCES)
    add_library(scitbx_minpack SHARED ${SCITBX_MINPACK_SOURCES})
    set_target_properties(scitbx_minpack PROPERTIES
        OUTPUT_NAME "scitbx_minpack"
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )
endif()

# Build libscitbx_slatec library
file(GLOB SCITBX_SLATEC_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/slatec/*.cpp")
list(FILTER SCITBX_SLATEC_SOURCES EXCLUDE REGEX ".*_ext\\.cpp$")
if(SCITBX_SLATEC_SOURCES)
    add_library(scitbx_slatec SHARED ${SCITBX_SLATEC_SOURCES})
    set_target_properties(scitbx_slatec PROPERTIES
        OUTPUT_NAME "scitbx_slatec"
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )
endif()

# Auto-detect and build all *_ext.cpp files as Python extension modules
file(GLOB_RECURSE SCITBX_ALL_EXT_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*_ext.cpp")

set(SCITBX_EXT_TARGETS "")
foreach(ext_source ${SCITBX_ALL_EXT_SOURCES})
    # Get the relative path and create module name
    file(RELATIVE_PATH rel_path ${CMAKE_CURRENT_SOURCE_DIR} ${ext_source})
    string(REPLACE "/" "_" module_name "${rel_path}")
    string(REPLACE ".cpp" "" module_name "${module_name}")
    string(PREPEND module_name "scitbx_")

    add_python_module(${module_name}
        SOURCES ${ext_source}
    )
    list(APPEND SCITBX_EXT_TARGETS ${module_name})
endforeach()

# Export targets for parent CMakeLists.txt
set(SCITBX_ALL_TARGETS ${SCITBX_EXT_TARGETS} PARENT_SCOPE)

message(STATUS "Added module: scitbx with ${CMAKE_MATCH_COUNT} extension modules")

# Install all Python files
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
    DESTINATION lib/scitbx
    FILES_MATCHING
    PATTERN "*.py"
    PATTERN "__pycache__" EXCLUDE
    PATTERN "build" EXCLUDE
    PATTERN ".git" EXCLUDE
)

# Install header files if needed
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
    DESTINATION include/scitbx
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*.hpp"
    PATTERN "__pycache__" EXCLUDE
    PATTERN "build" EXCLUDE
)
