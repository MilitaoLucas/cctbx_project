"""Update the installed libtbx_env so modules resolve from site-packages.

Mirrors the post-install step used by the Nix packaging (nix/cctbx.nix), but
adapted for a Python wheel where the libtbx_env lives at
<site-packages>/libtbx/core/share/cctbx and ``sys.prefix`` is not the install
root.  ``env_config.get_installed_path`` is patched so libtbx.load_env locates
the env we just staged, and the module dist paths are re-anchored to the wheel
root.
"""
from __future__ import absolute_import, division, print_function

import os
import os.path as op

from libtbx import env_config
from libtbx.path import relocatable_path


def _reanchor(path, anchor):
  """Reset a relocatable_path's anchor and recompute its relative string so it
  resolves from ``anchor`` (the env dir).  ``abs()`` before the rewrite gives the
  absolute staging target; its relationship to the env dir is fixed (always
  ``../../../../<module>``), so re-anchoring makes it relocatable."""
  if path is None or not isinstance(path, relocatable_path):
    return
  target = op.abspath(op.join(abs(path.anchor), path.relocatable))
  path._anchor = anchor
  path.relocatable = op.relpath(target, abs(anchor))


def main():
  prefix = os.environ["PREFIX"]
  default_dir = os.path.join(prefix, "libtbx", "core", "share", "cctbx")

  # update_libtbx_env writes dispatchers into <prefix>/bin.
  os.makedirs(os.path.join(prefix, "bin"), exist_ok=True)

  # Point libtbx at the staged env during this one-time rewrite.
  env_config.get_installed_path = lambda: default_dir

  import libtbx.load_env

  # Skip command-line directory processing while rewriting module paths.
  def skip_command_line_directories(self):
    pass

  for module in libtbx.env.module_list:
    type(module).process_command_line_directories = skip_command_line_directories

  from libtbx.auto_build.conda_build import update_libtbx_env

  update_libtbx_env.update_libtbx_env(default_dir=default_dir)

  # Re-anchor module dist paths to env.build_path so that unpickle()'s
  # build_path.reset() (to get_installed_path()) rewrites them for the actual
  # install location at runtime.  Only the module paths keep their own anchor;
  # bin/repository paths are re-anchored to sys.prefix by unpickle().
  env = libtbx.env
  anchor = env.build_path
  for name in env.module_dict:
    module = env.module_dict[name]
    for dp in module.dist_paths:
      _reanchor(dp, anchor)
    _reanchor(env.module_dist_paths.get(name), anchor)

  env.pickle()
  print("updated libtbx_env at %s" % default_dir)
  return 0


if __name__ == "__main__":
  raise SystemExit(main())
