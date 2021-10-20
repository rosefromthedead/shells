{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    {
      devShells.haskell = pkgs.mkShell {
        packages = with pkgs; [ ghc haskell-language-server haskellPackages.QuickCheck ];
      };
    }
  );
}
