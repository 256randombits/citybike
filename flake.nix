{
  description = "Citybikes";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ]
      (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          packages = rec { };
          apps = rec { } //
            (import ./citybike-backend/sqitch-migrations/sqitch.nix
              { inherit pkgs flake-utils; }).apps;

          devShells = {
            default = pkgs.mkShell {
              nativeBuildInputs = with pkgs;
                [
                  sqitchPg
                  postgresql_15 # Needed for psql
                ];
            };
          };
        });
}
