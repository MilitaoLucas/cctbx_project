# mmtbx - Macromolecular crystallography toolbox
project(mmtbx)

# Python package directory
set(MMTBX_PYTHON_DIR ${CMAKE_CURRENT_SOURCE_DIR})

# Note: The probe subdirectory has its own standalone CMakeLists.txt
# that expects CCTBX to already be built and installed.
# It's disabled here to avoid circular dependencies.
# To build probe separately, use its own CMakeLists.txt after CCTBX is installed.
#
# if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/probe/CMakeLists.txt)
#     add_subdirectory(probe)
# endif()

# Add Python modules to be installed
install(DIRECTORY ${MMTBX_PYTHON_DIR}/
    DESTINATION lib/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages/mmtbx
    FILES_MATCHING
    PATTERN "*.py"
    PATTERN "__pycache__" EXCLUDE
    PATTERN "*.pyc" EXCLUDE
)

message(STATUS "Added module: mmtbx")

