if(CCTBX_BUILD_PYTHON)
  cctbx_add_python_extension(cma_es_ext
    SOURCES
      cma_es_ext.cpp
      cma/cmaes.cpp
    LIBRARIES scitbx_boost_python
  )
  target_include_directories(cma_es_ext PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
  )
endif()
