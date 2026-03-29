{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Dependencies required at run-time.
        buildInputs = with pkgs; [ dart ];

        # Dependencies required at build-time.
        nativeBuildInputs = with pkgs; [ ];
      in
      {
        # Development shell with: nix develop
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ ] ++ buildInputs ++ nativeBuildInputs;

          # DART_ROOT = pkgs.dart;
        };
      }
    );
}
