if(CCTBX_BUILD_PYTHON)
  cctbx_add_python_extension(boost_python_meta_ext
    SOURCES meta_ext.cpp
    LIBRARIES scitbx_boost_python
  )
  target_compile_definitions(boost_python_meta_ext PRIVATE USE_CONDA)

  cctbx_add_python_extension(boost_optional_ext
    SOURCES optional_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(boost_tuple_ext
    SOURCES tuple_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(std_pair_ext
    SOURCES std_pair_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(boost_rational_ext
    SOURCES rational_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(boost_adaptbx_python_streambuf_test_ext
    SOURCES tests/python_streambuf_test_ext.cpp
    LIBRARIES scitbx_boost_python Boost::timer
  )

  cctbx_add_python_extension(boost_adaptbx_boost_thread_test_ext
    SOURCES tests/boost_thread_test.cpp
    LIBRARIES scitbx_boost_python Boost::thread
  )

  cctbx_add_python_extension(boost_python_hybrid_times_ext
    SOURCES hybrid_times_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(boost_adaptbx_graph_ext
    SOURCES graph/graph_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(boost_adaptbx_graph_connected_component_algorithm_ext
    SOURCES graph/connected_component_algorithm_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(boost_adaptbx_graph_breadth_first_search_ext
    SOURCES graph/breadth_first_search_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(boost_adaptbx_graph_graph_structure_comparison_ext
    SOURCES graph/graph_structure_comparison_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(boost_adaptbx_graph_maximum_clique_ext
    SOURCES graph/maximum_clique_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(boost_adaptbx_graph_min_cut_max_flow_ext
    SOURCES graph/min_cut_max_flow_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(boost_adaptbx_graph_utility_ext
    SOURCES graph/utility_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(boost_adaptbx_graph_metric_ext
    SOURCES graph/metric_ext.cpp
    LIBRARIES scitbx_boost_python
  )

  cctbx_add_python_extension(boost_adaptbx_graph_clustering_algorithm_ext
    SOURCES graph/clustering_algorithm_ext.cpp
    LIBRARIES scitbx_boost_python
  )
endif()
