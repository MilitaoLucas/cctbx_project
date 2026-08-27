add_library(omptbx SHARED stubs.cpp)
target_link_libraries(omptbx PUBLIC cctbx_build_options)
target_include_directories(omptbx PUBLIC
  $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
)
set_target_properties(omptbx PROPERTIES OUTPUT_NAME omptbx)

install(TARGETS omptbx
  EXPORT cctbxTargets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

if(CCTBX_BUILD_PYTHON)
  cctbx_add_python_extension(omptbx_ext
    SOURCES ext.cpp
    LIBRARIES omptbx scitbx_boost_python
  )
  target_include_directories(omptbx_ext PRIVATE
    ${PROJECT_SOURCE_DIR}
  )
endif()
