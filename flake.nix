{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };
  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
          nativeBuildInputs = with pkgs; [ 
            rustToolchain 
            rust-analyzer-unwrapped 
            pkg-config
          ];
          buildInputs = with pkgs; [
            darwin.apple_sdk.frameworks.SystemConfiguration
          ];
        in
        with pkgs;
        {
          devShells.default = mkShell {
            inherit buildInputs nativeBuildInputs;

            packages = [ ];
            RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          };
        }
      );
}