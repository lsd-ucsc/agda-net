nix-shell -p '
agda.withPackages {
    pkgs = [ agdaPackages.standard-library ];
    ghc = haskellPackages.ghcWithPackages (p: with p; [ ieee754 network-simple ]);
}'
