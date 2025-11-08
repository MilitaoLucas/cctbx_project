# serialtbx - Serial crystallography toolbox
project(serialtbx)

# Python package directory
set(SERIALTBX_PYTHON_DIR ${CMAKE_CURRENT_SOURCE_DIR})

# Add Python modules to be installed
install(DIRECTORY ${SERIALTBX_PYTHON_DIR}/
    DESTINATION lib/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages/serialtbx
    FILES_MATCHING
    PATTERN "*.py"
    PATTERN "__pycache__" EXCLUDE
    PATTERN "*.pyc" EXCLUDE
)

message(STATUS "Added module: serialtbx")

