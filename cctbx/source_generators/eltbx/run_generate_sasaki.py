#!/usr/bin/env python
"""
Wrapper script to generate cctbx sasaki source files.
This is called by CMake during the build process.
"""
from __future__ import absolute_import, division, print_function

import os
import sys
import types

# Mock libtbx package structure before importing anything
# This avoids the FileNotFoundError when libtbx.load_env tries to unpickle
class MockEnv:
    def under_dist(self, module_name, relative_path):
        """Mock implementation of libtbx.env.under_dist()"""
        project_root = os.path.join(os.path.dirname(__file__), '..', '..', '..')
        project_root = os.path.abspath(project_root)
        return os.path.join(project_root, module_name, relative_path)

# Add project root to Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..'))

# Create a complete mock libtbx package structure
libtbx_module = types.ModuleType('libtbx')
libtbx_module.__package__ = 'libtbx'
libtbx_module.__path__ = []
libtbx_module.env = MockEnv()

# Mock submodules
libtbx_module.load_env = types.ModuleType('libtbx.load_env')
libtbx_module.forward_compatibility = types.ModuleType('libtbx.forward_compatibility')

# Mock libtbx.utils with write_this_is_auto_generated function
libtbx_utils = types.ModuleType('libtbx.utils')
def write_this_is_auto_generated(f, file_name_generator=""):
    """Mock implementation of write_this_is_auto_generated"""
    print("// This file is auto-generated", file=f)
    if file_name_generator:
        print("// Generator:", file_name_generator, file=f)
libtbx_utils.write_this_is_auto_generated = write_this_is_auto_generated
libtbx_module.utils = libtbx_utils

# Register all mocks in sys.modules
sys.modules['libtbx'] = libtbx_module
sys.modules['libtbx.load_env'] = libtbx_module.load_env
sys.modules['libtbx.forward_compatibility'] = libtbx_module.forward_compatibility
sys.modules['libtbx.utils'] = libtbx_utils

# Now import the generator module
import importlib.util
spec = importlib.util.spec_from_file_location(
    "generate_sasaki_cpp",
    os.path.join(os.path.dirname(__file__), "generate_sasaki_cpp.py")
)
generate_sasaki_cpp = importlib.util.module_from_spec(spec)
spec.loader.exec_module(generate_sasaki_cpp)

# Get the eltbx directory path
# This script is in cctbx/source_generators/eltbx/
# We need to pass cctbx/eltbx/ to the run function
script_dir = os.path.dirname(os.path.abspath(__file__))
source_generators_dir = os.path.dirname(script_dir)  # cctbx/source_generators/
cctbx_dir = os.path.dirname(source_generators_dir)  # cctbx/
eltbx_dir = os.path.join(cctbx_dir, "eltbx")

if not os.path.isdir(eltbx_dir):
    print("ERROR: eltbx directory not found at:", eltbx_dir)
    sys.exit(1)

print("Generating cctbx sasaki source files...")
generate_sasaki_cpp.run(eltbx_dir)
print("Sasaki generation complete!")
