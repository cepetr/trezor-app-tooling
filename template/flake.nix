{
  description = "Development environment for trezor-app-tooling";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/a07d4ce6bee67d7c838a8a5796e75dff9caa21ef";
    rust-overlay = {
      url = "github:oxalica/rust-overlay/f600ea449c7b5bb596fa1cf21c871cc5b9e31316";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };

        rustNightly = pkgs.rust-bin.nightly."2026-02-26".minimal.override {
          targets = [
            "thumbv8m.main-none-eabihf"
          ];
          extensions = [ "rust-src" "clippy" "rustfmt" "llvm-tools-preview" ];
        };

        rustSrc = pkgs.rust-bin.nightly."2026-02-26".rust-src;

        trezorAppGenerate = pkgs.writeShellScriptBin "trezor-app-generate" ''
          exec cargo generate \
            --git https://github.com/cepetr/trezor-app-tooling.git \
            template \
            "$@"
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustNightly
            cargo-generate
            trezorAppGenerate
            cargo-binutils
            pkgsCross.arm-embedded.buildPackages.binutils
            llvmPackages.clang
            llvmPackages.llvm
            python3
            uv
            protobuf
            pyright
            pkg-config
            openssl
            zlib
            libffi
            libusb1
            libjpeg
          ];

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.libffi
            pkgs.libjpeg
            pkgs.libusb1
            pkgs.libressl
          ];
          DYLD_LIBRARY_PATH = "${pkgs.libffi}/lib:${pkgs.libjpeg.out}/lib:${pkgs.libusb1}/lib:${pkgs.libressl.out}/lib";
          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
          RUST_SRC_PATH = "${rustSrc}/lib/rustlib/src/rust/library";

          # shellHook = ''
          #   export CARGO_INSTALL_ROOT="$TMPDIR/trezor-app-tool"
          #   export PATH="$CARGO_INSTALL_ROOT/bin:$PATH"
          #   cargo install --root "$CARGO_INSTALL_ROOT" --path /home/pcernin/repos/trezor-firmware/sdk/crates/trezor-app-tool
          # '';
        };
      });
}