# Runs libtbx/configure.py into <build>/cctbx_build, producing the libtbx_env
# file required by libtbx.load_env to bootstrap Python imports.  Mirrors the
# preConfigure step in nix/cctbx.nix.
function(cctbx_generate_libtbx_env)
  set(_shim_dir "${CMAKE_BINARY_DIR}/libtbx_shims")
  set(_build_dir "${CMAKE_BINARY_DIR}/cctbx_build")
  set(_env_file "${_build_dir}/libtbx_env")

  set(_shims "")
  foreach(_pkg future pip)
    execute_process(
      COMMAND "${Python3_EXECUTABLE}" -c "import ${_pkg}"
      RESULT_VARIABLE _import_rc
      OUTPUT_QUIET
      ERROR_QUIET
    )
    if(NOT _import_rc EQUAL 0)
      file(MAKE_DIRECTORY "${_shim_dir}/${_pkg}")
      file(WRITE "${_shim_dir}/${_pkg}/__init__.py" "__version__ = \"0\"\n")
      set(_shims "${_shim_dir}")
    endif()
  endforeach()

  set(_modules cctbx)
  if(CCTBX_BUILD_SMTBX)
    list(APPEND _modules smtbx)
  endif()

  add_custom_command(
    OUTPUT "${_env_file}"
    COMMAND ${CMAKE_COMMAND} -E make_directory "${_build_dir}"
    COMMAND ${CMAKE_COMMAND} -E env
      "PYTHONPATH=${_shims}:$ENV{PYTHONPATH}"
      "${Python3_EXECUTABLE}" "${PROJECT_SOURCE_DIR}/libtbx/configure.py"
      --current_working_directory "${_build_dir}"
      --no_bin_python
      -r "${PROJECT_SOURCE_DIR}"
      ${_modules}
    WORKING_DIRECTORY "${_build_dir}"
    DEPENDS "${PROJECT_SOURCE_DIR}/libtbx/configure.py"
    VERBATIM
  )
  add_custom_target(cctbx_libtbx_env ALL DEPENDS "${_env_file}")
endfunction()
