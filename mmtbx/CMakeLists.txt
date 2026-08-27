if(CCTBX_BUILD_PYTHON)
  add_library(mmtbx_tls SHARED tls/decompose.cpp)
  target_link_libraries(mmtbx_tls PUBLIC cctbx_build_options m)
  set_target_properties(mmtbx_tls PROPERTIES OUTPUT_NAME mmtbx_tls)

  cctbx_add_python_extension(mmtbx_tls_ext
    SOURCES tls/tls_ext.cpp
    LIBRARIES mmtbx_tls cctbx_core scitbx_boost_python
  )

  cctbx_add_python_extension(mmtbx_reference_coordinate_ext
    SOURCES geometry_restraints/boost_python/reference_coordinate_ext.cpp
    LIBRARIES cctbx_core scitbx_boost_python
  )

  install(TARGETS mmtbx_tls
    EXPORT cctbxTargets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )
endif()
