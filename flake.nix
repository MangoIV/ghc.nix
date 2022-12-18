{
  description = "ghc.nix - the ghc devShell";
  nixConfig.bash-prompt = "\\e[34;1mghc.nix ~ \\e[0m";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    all-cabal-hashes = {
      url = "github:commercialhaskell/all-cabal-hashes/hackage";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, all-cabal-hashes, ... }: with nixpkgs.lib; let
    supportedSystems = nixpkgs.lib.systems.flakeExposed;
    perSystem = genAttrs supportedSystems;
    pkgsFor = system: import nixpkgs { inherit system; };
    unstablePkgsFor = system: import nixpkgs-unstable { inherit system; };
  in
  {
    devShells = perSystem (system: rec {
      ghc-nix = import ./ghc.nix {
        inherit system;
        all-cabal-hashes = all-cabal-hashes.outPath;
        withHadrianDeps = true;
        withIde = true;
        nixpkgs = pkgsFor system;
        nixpkgs-unstable = unstablePkgsFor system;
      };

      default = ghc-nix;
    });
    formatter = perSystem (system: (pkgsFor system).nixpkgs-fmt);
  };
}
