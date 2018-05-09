{ compiler ? "ghc822" }:
let
  config = {
    packageOverrides = pkgs: rec {
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          "${compiler}" = pkgs.haskell.packages."${compiler}".override {
            overrides = hspkgsNew: hspkgsOld: rec {
              shlug-s0 = hspkgsNew.callPackage ./default.nix {};
              shlug-s0-static =
                pkgs.haskell.lib.overrideCabal
              (pkgs.haskell.lib.justStaticExecutables (hspkgsNew.callPackage ./default.nix {}))
              (oldDerivation: {
                configureFlags = [
                  "--ghc-option=-optl=-static"
                  "--ghc-option=-optl=-pthread"
                  "--ghc-option=-optl=-L${pkgs.gmp5.static}/lib"
                  "--ghc-option=-optl=-L${pkgs.zlib.static}/lib"
                  "--ghc-option=-optl=-L${pkgs.glibc.static}/lib"
                ];
              });
            };
          };
        };
      };
    };
  };
  pkgs = import <nixpkgs> { inherit config; };
in
{
  shlug-s0 = pkgs.haskell.packages.${compiler}.shlug-s0;
  shlug-s0-static = pkgs.haskell.packages.${compiler}.shlug-s0-static;
}
