#!/usr/bin/env python
"""
Wrapper script to generate cctbx flex_fwd.h header.
This is called by CMake during the build process.
"""
from __future__ import absolute_import, division, print_function

import os
import sys
import types

# Mock libtbx package structure
class MockBuildOptions:
    """Mock build options"""
    write_full_flex_fwd_h = True  # Generate full flex_fwd.h by default

class MockEnv:
    def __init__(self):
        self.build_options = MockBuildOptions()

    def under_dist(self, module_name, relative_path):
        project_root = os.path.join(os.path.dirname(__file__), '..', '..')
        project_root = os.path.abspath(project_root)
        return os.path.join(project_root, module_name, relative_path)

# Add project root to Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

# Create mock libtbx package
libtbx_module = types.ModuleType('libtbx')
libtbx_module.__package__ = 'libtbx'
libtbx_module.__path__ = []
libtbx_module.env = MockEnv()

libtbx_module.load_env = types.ModuleType('libtbx.load_env')
libtbx_module.forward_compatibility = types.ModuleType('libtbx.forward_compatibility')

libtbx_utils = types.ModuleType('libtbx.utils')
def write_this_is_auto_generated(f, file_name_generator=""):
    print("// This file is auto-generated", file=f)
    if file_name_generator:
        print("// Generator:", file_name_generator, file=f)
libtbx_utils.write_this_is_auto_generated = write_this_is_auto_generated
libtbx_module.utils = libtbx_utils

sys.modules['libtbx'] = libtbx_module
sys.modules['libtbx.load_env'] = libtbx_module.load_env
sys.modules['libtbx.forward_compatibility'] = libtbx_module.forward_compatibility
sys.modules['libtbx.utils'] = libtbx_utils

# Import the generator module
import importlib.util
spec = importlib.util.spec_from_file_location(
    "flex_fwd_h",
    os.path.join(os.path.dirname(__file__), "flex_fwd_h.py")
)
flex_fwd_h = importlib.util.module_from_spec(spec)
spec.loader.exec_module(flex_fwd_h)

# Get the boost_python directory path
script_dir = os.path.dirname(os.path.abspath(__file__))
cctbx_dir = os.path.dirname(script_dir)
boost_python_dir = os.path.join(cctbx_dir, "boost_python")

if not os.path.isdir(boost_python_dir):
    print("ERROR: boost_python directory not found at:", boost_python_dir)
    sys.exit(1)

print("Generating cctbx/boost_python/flex_fwd.h...")
flex_fwd_h.run(boost_python_dir)
print("flex_fwd.h generation complete!")

