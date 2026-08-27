# Defines the cctbx_add_python_extension() function used by every module
# that ships boost_python bindings.  Requires the Python3 and Boost
# components resolved in the top-level CMakeLists.txt:
#   Python3::Module, Python3::NumPy, Boost::${_boost_python_component},
#   Boost::${_boost_numpy_component}
# Every extension is registered with the cctbxTargets export set.
function(cctbx_add_python_extension target)
  cmake_parse_arguments(ARG "" "" "SOURCES;LIBRARIES" ${ARGN})
  Python3_add_library(${target} MODULE ${ARG_SOURCES} WITH_SOABI)
  target_link_libraries(${target} PRIVATE
    cctbx_build_options
    Python3::Module
    Python3::NumPy
    Boost::${_boost_python_component}
    Boost::${_boost_numpy_component}
    ${ARG_LIBRARIES}
  )
  target_include_directories(${target} PRIVATE
    ${PROJECT_SOURCE_DIR}
    ${PROJECT_BINARY_DIR}/include
    Python3::NumPy
  )
  add_dependencies(${target} cctbx_generated_headers)
  set_target_properties(${target} PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/python"
  )
  install(TARGETS ${target}
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages"
  )
endfunction()
