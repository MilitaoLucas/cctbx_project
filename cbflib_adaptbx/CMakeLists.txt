# cbflib_adaptbx module

# Check if cbflib exists
if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/../modules/cbflib)
    message(WARNING "cbflib not found, skipping cbflib_adaptbx")
    return()
endif()

set(CBFLIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../modules/cbflib)

# CBFlib include directories
set(CBFLIB_INCLUDE_DIRS
    ${CBFLIB_DIR}/examples
    ${CBFLIB_DIR}/include
    ${CBFLIB_DIR}/src
)

# CBFlib source files
set(CBFLIB_SOURCES
    ${CBFLIB_DIR}/src/img.c
    ${CBFLIB_DIR}/src/cbf.c
    ${CBFLIB_DIR}/src/cbf_alloc.c
    ${CBFLIB_DIR}/src/cbf_ascii.c
    ${CBFLIB_DIR}/src/cbf_binary.c
    ${CBFLIB_DIR}/src/cbf_byte_offset.c
    ${CBFLIB_DIR}/src/cbf_canonical.c
    ${CBFLIB_DIR}/src/cbf_codes.c
    ${CBFLIB_DIR}/src/cbf_compress.c
    ${CBFLIB_DIR}/src/cbf_context.c
    ${CBFLIB_DIR}/src/cbf_file.c
    ${CBFLIB_DIR}/src/cbf_lex.c
    ${CBFLIB_DIR}/src/cbf_nibble_offset.c
    ${CBFLIB_DIR}/src/cbf_packed.c
    ${CBFLIB_DIR}/src/cbf_predictor.c
    ${CBFLIB_DIR}/src/cbf_read_binary.c
    ${CBFLIB_DIR}/src/cbf_read_mime.c
    ${CBFLIB_DIR}/src/cbf_simple.c
    ${CBFLIB_DIR}/src/cbf_string.c
    ${CBFLIB_DIR}/src/cbf_stx.c
    ${CBFLIB_DIR}/src/cbf_tree.c
    ${CBFLIB_DIR}/src/cbf_uncompressed.c
    ${CBFLIB_DIR}/src/cbf_write.c
    ${CBFLIB_DIR}/src/cbf_write_binary.c
    ${CBFLIB_DIR}/src/md5c.c
)

# Check for cbf_ws.c (CBFlib 0.9.2 and later)
if(EXISTS ${CBFLIB_DIR}/src/cbf_ws.c)
    list(APPEND CBFLIB_SOURCES ${CBFLIB_DIR}/src/cbf_ws.c)
endif()

# Build CBFlib as a static library
add_library(cbf STATIC ${CBFLIB_SOURCES})

target_include_directories(cbf PUBLIC
    ${CBFLIB_INCLUDE_DIRS}
)

target_compile_definitions(cbf PRIVATE
    CBF_NO_REGEX
)

if(MSVC)
    target_compile_definitions(cbf PRIVATE
        malloc=malloc
        free=free
    )
endif()

# HDF5 support
if(HDF5_FOUND)
    target_include_directories(cbf PUBLIC ${HDF5_INCLUDE_DIRS})
    target_link_libraries(cbf PUBLIC ${HDF5_LIBRARIES})
endif()

# CBF adaptor sources
set(CBFLIB_ADAPTBX_SOURCES
    detectors/mar_adaptor.cpp
    detectors/cbf_adaptor.cpp
)

# Build adaptor extensions (if they exist)
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/detectors)
    # You would add Python modules here if needed
    # For now, just include the directory
    include_directories(${CMAKE_CURRENT_SOURCE_DIR})
endif()

# Install Python files
file(GLOB PYTHON_FILES "*.py")
if(PYTHON_FILES)
    install(FILES ${PYTHON_FILES}
        DESTINATION lib/cbflib_adaptbx
    )
endif()

# Install subdirectories
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/command_line)
    install(DIRECTORY command_line
        DESTINATION lib/cbflib_adaptbx
        FILES_MATCHING PATTERN "*.py"
    )
endif()

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/detectors)
    install(DIRECTORY detectors
        DESTINATION lib/cbflib_adaptbx
        FILES_MATCHING PATTERN "*.py"
    )
endif()

