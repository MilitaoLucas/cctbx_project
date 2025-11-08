#!/usr/bin/env python
"""
Wrapper script to generate scitbx array_family source files.
This is called by CMake during the build process.
"""
from __future__ import absolute_import, division, print_function

import os
import sys

# Import the generator module directly without going through scitbx package
# to avoid libtbx.env initialization issues
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..'))

# Import as a standalone module
import importlib.util
spec = importlib.util.spec_from_file_location(
    "generate_all",
    os.path.join(os.path.dirname(__file__), "generate_all.py")
)
generate_all = importlib.util.module_from_spec(spec)
spec.loader.exec_module(generate_all)

# Get the array_family directory path
# This script is in scitbx/source_generators/array_family/
# We need to pass scitbx/array_family/ to the refresh function
script_dir = os.path.dirname(os.path.abspath(__file__))
source_generators_dir = os.path.dirname(script_dir)  # scitbx/source_generators/
scitbx_dir = os.path.dirname(source_generators_dir)  # scitbx/
array_family_dir = os.path.join(scitbx_dir, "array_family")

if not os.path.isdir(array_family_dir):
    print("ERROR: array_family directory not found at:", array_family_dir)
    sys.exit(1)

print("Generating scitbx array_family source files...")
generate_all.refresh(array_family_dir)
print("Generation complete!")
