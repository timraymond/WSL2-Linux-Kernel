{
  description = "WSL2 Linux Kernel Build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
          pkgs = import nixpkgs { inherit system; };

          # Kernel version configuration
          kernelVersion = "5.15.153.1";
          kernelTag = "linux-msft-wsl-${kernelVersion}";

          kernel = pkgs.linuxPackagesFor (pkgs.linuxManualConfig rec {
            version = "${kernelVersion}-wsl";

            src = pkgs.applyPatches {
              src = ./.;
              patches = [];
            };

            allowImportFromDerivation = true;
            configfile = "${src}/Microsoft/config-wsl";
            modDirVersion = "${kernelVersion}-microsoft-standard-WSL2";
          });

        in {
          packages = {
            default = kernel.kernel;
            inherit kernel;
          };

          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              gcc
              gnumake
              binutils
              bc

              flex
              bison
              openssl
              libelf

              ncurses
              pkg-config

              git
              patch
            ];
          };
        }
      );
}
