{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages =
    with pkgs;
    [
      pkgs.git
      gcc

      llvmPackages.openmp

      # Dependencies from flake.nix devShell
      pkgs.cmake
      pkgs.boost
      (pkgs.python313Packages.boost.override { enableNumpy = true; })
      pkgs.eigen
      (pkgs.python313.withPackages (ps: [
        ps.numpy
        ps.setuptools
        ps.six
      ]))
    ]
    ++ [
      inputs.cctbx.packages.${pkgs.system}.ccp4io
      #    inputs.cctbx.packages.${pkgs.system}.cctbx
    ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;

  # https://devenv.sh/processes/
  # processes.dev.exec = "${lib.getExe pkgs.watchexec} -n -- ls -la";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';
  languages.python = {
    enable = true;
    venv.enable = true;
    package = pkgs.python313;
    uv = {
      enable = true;
      sync.enable = true;
    };
  };
  # https://devenv.sh/basics/
  enterShell = ''
    hello         # Run scripts directly
    git --version # Use packages
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
