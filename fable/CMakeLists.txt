if(CCTBX_BUILD_PYTHON)
  cctbx_add_python_extension(fable_ext
    SOURCES ext.cpp
    LIBRARIES scitbx_boost_python
  )
  target_include_directories(fable_ext PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
  )
endif()
