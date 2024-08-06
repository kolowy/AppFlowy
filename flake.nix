{
  description = "Appflowy flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    futils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    futils,
  } @ inputs: let
    inherit (nixpkgs) lib;
    inherit (lib) recursiveUpdate;
    inherit (futils.lib) eachDefaultSystem defaultSystems;

    nixpkgsFor = lib.genAttrs defaultSystems (system:
      import nixpkgs {
        inherit system;
      });
  in (eachDefaultSystem (
    system: let
      pkgs = nixpkgsFor.${system};
    in {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          ## Step 1 : Install your build environment
          git
          curl
          gcc

          sqlite
          openssl
          clang
          cmake
          ninja
          pkg-config
          gtk3
          unzip

          keybinder
          libnotify
          mpv

          rustc
          rustup
          rustfmt

          ## Step 2 : install flutter 3.22
          (pkgs.stdenv.mkDerivation {
            pname = "flutter";
            version = "3.22.0";
            src = pkgs.fetchFromGitHub {
              owner = "flutter";
              repo = "flutter";
              rev = "3.22.0";
              sha256 = "UcpprC40itt3nbvENJVytD8M1EYSjKMlpAWJ+GmN7Pg=";
            };

            phases = ["installPhase"];

            installPhase = ''
              mkdir -p $out/bin
              cp -r * $out/bin
            '';
          })

          go
          dart
        ];

        shellHook = ''
          # Init rustup
          rustup default stable

          # Enable linux desktop
          if ! flutter config --list | grep -q 'enable-linux-desktop: true'; then
            flutter config --enable-linux-desktop
          fi

          # Fix any problems reported by flutter doctor
          flutter doctor

          # Add the githooks directory to your git configuration
          git config core.hooksPath .githooks


          ## Step 3 : Build AppFlowy (Flutter GUI application)
          pushd frontend

          if ! cargo make --version &>/dev/null; then
            cargo install --force cargo-make
          fi

          if ! duck --version &>/dev/null; then
            cargo install --force duckscript_cli
          fi

          cargo make appflowy-flutter-deps-tools

          cargo make --profile production-linux-x86_64 appflowy
          popd

          echo "Welcome to the Appflowy development shell!"
        '';
      };
    }
  ));
}
