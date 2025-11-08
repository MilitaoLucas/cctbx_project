# boost_adaptbx module

# Build main boost_adaptbx extensions
add_python_module(boost_python_hybrid_times_ext
    SOURCES hybrid_times_ext.cpp
)

add_python_module(boost_python_meta_ext
    SOURCES meta_ext.cpp
)

add_python_module(boost_optional_ext
    SOURCES optional_ext.cpp
)

add_python_module(boost_rational_ext
    SOURCES rational_ext.cpp
)

add_python_module(std_pair_ext
    SOURCES std_pair_ext.cpp
)

add_python_module(boost_tuple_ext
    SOURCES tuple_ext.cpp
)

# Graph extensions
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/graph/graph_ext.cpp)
    add_python_module(boost_adaptbx_graph_ext
        SOURCES graph/graph_ext.cpp
    )

    add_python_module(boost_adaptbx_graph_connected_component_algorithm_ext
        SOURCES graph/connected_component_algorithm_ext.cpp
    )

    add_python_module(boost_adaptbx_graph_breadth_first_search_ext
        SOURCES graph/breadth_first_search_ext.cpp
    )

    add_python_module(boost_adaptbx_graph_graph_structure_comparison_ext
        SOURCES graph/graph_structure_comparison_ext.cpp
    )

    add_python_module(boost_adaptbx_graph_maximum_clique_ext
        SOURCES graph/maximum_clique_ext.cpp
    )

    add_python_module(boost_adaptbx_graph_min_cut_max_flow_ext
        SOURCES graph/min_cut_max_flow_ext.cpp
    )

    add_python_module(boost_adaptbx_graph_utility_ext
        SOURCES graph/utility_ext.cpp
    )

    add_python_module(boost_adaptbx_graph_metric_ext
        SOURCES graph/metric_ext.cpp
    )

    add_python_module(boost_adaptbx_graph_clustering_algorithm_ext
        SOURCES graph/clustering_algorithm_ext.cpp
    )
endif()

# Boost.Thread test extension (if thread support is enabled)
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/tests/tst_parallel_for_segfault.cpp)
    add_python_module(boost_adaptbx_boost_thread_test_ext
        SOURCES tests/tst_parallel_for_segfault.cpp
    )
endif()

# Python streambuf test extension
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/tests/tst_python_streambuf.cpp)
    add_python_module(boost_adaptbx_python_streambuf_test_ext
        SOURCES tests/tst_python_streambuf.cpp
    )
endif()

# Install Python files
install(FILES
    __init__.py
    optional.py
    python.py
    rational.py
    std_pair.py
    tuple.py
    hybrid_times.py
    main.py
    run_tests.py
    DESTINATION lib/boost_adaptbx
)

# Install subdirectories
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/command_line)
    install(DIRECTORY command_line
        DESTINATION lib/boost_adaptbx
        FILES_MATCHING PATTERN "*.py"
    )
endif()

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/graph)
    install(DIRECTORY graph
        DESTINATION lib/boost_adaptbx
        FILES_MATCHING PATTERN "*.py"
    )
endif()

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/tests)
    install(DIRECTORY tests
        DESTINATION lib/boost_adaptbx
        FILES_MATCHING PATTERN "*.py"
    )
endif()

