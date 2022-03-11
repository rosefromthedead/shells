{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.circuitflow = {
    url = "github:rosehuds/CircuitFlow";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, circuitflow }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      ghc-with-packages = pkgs.haskellPackages.ghcWithPackages (pkgs:
        [ pkgs.QuickCheck circuitflow.packages.${system}.CircuitFlow ]
      );
      jdtls = pkgs.callPackage ./jdtls.nix {};
    in
    {
      devShells.haskell = pkgs.mkShell {
        packages = with pkgs; [ ghc-with-packages cabal-install haskell-language-server ];
      };
      devShells.java = pkgs.mkShell {
        packages = with pkgs; [ jdk jdtls maven ];
      };
    }
  );
}
