# kokkostbx - Kokkos toolbox for portable parallel programming
project(kokkostbx)

# Python package directory
set(KOKKOSTBX_PYTHON_DIR ${CMAKE_CURRENT_SOURCE_DIR})

# Add Python modules to be installed
install(DIRECTORY ${KOKKOSTBX_PYTHON_DIR}/
    DESTINATION lib/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages/kokkostbx
    FILES_MATCHING
    PATTERN "*.py"
    PATTERN "__pycache__" EXCLUDE
    PATTERN "*.pyc" EXCLUDE
)

message(STATUS "Added module: kokkostbx")

