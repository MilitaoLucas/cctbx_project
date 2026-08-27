if(CCTBX_BUILD_PYTHON)
  add_library(xcif SHARED
    data_model.cpp
    tokenizer.cpp
    numeric.cpp
  )
  target_link_libraries(xcif PUBLIC cctbx_build_options)
  target_include_directories(xcif PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
  )
  set_target_properties(xcif PROPERTIES OUTPUT_NAME xcif)

  cctbx_add_python_extension(xcif_ext
    SOURCES xcif_ext.cpp
    LIBRARIES xcif scitbx_boost_python
  )

  install(TARGETS xcif
    EXPORT cctbxTargets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )
endif()
