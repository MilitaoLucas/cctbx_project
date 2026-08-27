add_library(fast_linalg SHARED np_ext.cpp)
target_link_libraries(fast_linalg PRIVATE cctbx_build_options ${CMAKE_DL_LIBS})
set_target_properties(fast_linalg PROPERTIES OUTPUT_NAME fast_linalg)

install(TARGETS fast_linalg
  EXPORT cctbxTargets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

if(CCTBX_BUILD_PYTHON)
  cctbx_add_python_extension(fast_linalg_ext
    SOURCES ext.cpp
    LIBRARIES fast_linalg scitbx_boost_python
  )
endif()
