{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
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
    in
    {
      devShells.haskell = pkgs.mkShell {
        packages = with pkgs; [ ghc-with-packages haskell-language-server ];
      };
    }
  );
}
