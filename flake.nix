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

  outputs = { self, nixpkgs, nixpkgs-unstable, all-cabal-hashes, ... }: with nixpkgs.lib; let
    supportedSystems = systems.flakeExposed;
    perSystem = genAttrs supportedSystems;
    pkgsFor = system: import nixpkgs { inherit system; };
    unstablePkgsFor = system: import nixpkgs-unstable { inherit system; };

    defaultSettings = system: {
      inherit system;
      all-cabal-hashes = all-cabal-hashes.outPath;
      nixpkgs = pkgsFor system;
      nixpkgs-unstable = unstablePkgsFor system;
    };

    # NOTE: change this according to the settings allowed in the ./ghc.nix file and described 
    # in the `README.md`
    userSettings = {
      withHadrianDeps = true;
      withIde = true;
    };
  in
  {
    devShells = perSystem (system: rec {
      ghc-nix = import ./ghc.nix (defaultSettings system // userSettings);
      default = ghc-nix;
    });
    formatter = perSystem (system: (pkgsFor system).nixpkgs-fmt);

    # NOTE: this attribute is used by the flake-compat code to allow passing arguments to ./ghc.nix
    legacy = args: import ./ghc.nix (defaultSettings args.system // args);
  };
}
