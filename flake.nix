{
  description = "Citybikes";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    stations-csv = {
      url = "https://opendata.arcgis.com/datasets/726277c507ef4914b0aec3cbcfcbfafc_0.csv";
      flake = false;
    };
    journeys05-csv = {
      url = "https://dev.hsl.fi/citybikes/od-trips-2021/2021-05.csv";
      flake = false;
    };
    journeys06-csv = {
      url = "https://dev.hsl.fi/citybikes/od-trips-2021/2021-06.csv";
      flake = false;
    };
    journeys07-csv = {
      url = "https://dev.hsl.fi/citybikes/od-trips-2021/2021-07.csv";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, stations-csv, journeys05-csv, journeys06-csv, journeys07-csv }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ]
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          csvFiles = {
            inherit stations-csv journeys05-csv journeys06-csv journeys07-csv;
          };
        in
        {
          packages = rec { };
          apps = rec { }
            //
            (import ./citybike-backend/sqitch-migrations/sqitch.nix
              { inherit pkgs flake-utils; }).apps
            //
            (import ./citybike-backend/sqitch-migrations/data-import.nix
              { inherit pkgs flake-utils csvFiles; }).apps
            //
            (import ./citybike-frontend/frontend.nix
              { inherit pkgs flake-utils; }).apps;

          devShells = {
            default = pkgs.mkShell {
              nativeBuildInputs = with pkgs;
                [
                  sqitchPg
                  postgresql_15 # Needed for psql

                  elmPackages.elm
                  elmPackages.elm-live
                  elmPackages.elm-format
                  elmPackages.elm-language-server

                  nodePackages.tailwindcss
                ];
            };
          };
        });
}
