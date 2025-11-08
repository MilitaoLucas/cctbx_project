# xfel - X-ray Free Electron Laser data processing
project(xfel)

# Python package directory
set(XFEL_PYTHON_DIR ${CMAKE_CURRENT_SOURCE_DIR})

# Add Python modules to be installed
install(DIRECTORY ${XFEL_PYTHON_DIR}/
    DESTINATION lib/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages/xfel
    FILES_MATCHING
    PATTERN "*.py"
    PATTERN "__pycache__" EXCLUDE
    PATTERN "*.pyc" EXCLUDE
)

message(STATUS "Added module: xfel")

