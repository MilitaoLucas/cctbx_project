# clipper_adaptbx - Clipper library adapter
project(clipper_adaptbx)

# Python package directory
set(CLIPPER_ADAPTBX_PYTHON_DIR ${CMAKE_CURRENT_SOURCE_DIR})

# Add Python modules to be installed
install(DIRECTORY ${CLIPPER_ADAPTBX_PYTHON_DIR}/
    DESTINATION lib/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages/clipper_adaptbx
    FILES_MATCHING
    PATTERN "*.py"
    PATTERN "__pycache__" EXCLUDE
    PATTERN "*.pyc" EXCLUDE
)

message(STATUS "Added module: clipper_adaptbx")

