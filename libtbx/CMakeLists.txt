# libtbx (Library Toolbox) - Core infrastructure module

# Include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# Collect all Python extension source files (if any)
file(GLOB_RECURSE LIBTBX_EXT_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/*_ext.cpp"
)

# Build Python extension modules if they exist
if(LIBTBX_EXT_SOURCES)
    # Add your specific extension modules here
endif()

# Install all Python files
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
    DESTINATION lib/libtbx
    FILES_MATCHING
    PATTERN "*.py"
    PATTERN "__pycache__" EXCLUDE
    PATTERN "build" EXCLUDE
    PATTERN ".git" EXCLUDE
)

# Install header files
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
    DESTINATION include/libtbx
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*.hpp"
    PATTERN "__pycache__" EXCLUDE
    PATTERN "build" EXCLUDE
)

# Install utility scripts
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/auto_build)
    install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/auto_build
        DESTINATION lib/libtbx
        FILES_MATCHING PATTERN "*.py"
    )
endif()

