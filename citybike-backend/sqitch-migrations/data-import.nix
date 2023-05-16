{ pkgs, flake-utils, csvFiles, ... }:
let
  initCurl = pkgs.writeShellScript "init-curl.sh" ''
    PROJECTPATH=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
    source ''${PROJECTPATH}/citybike-backend/.env
    UPSTREAM=''${PGRST_UPSTREAM}:''${DEV_PGRST_PORT}
  '';
  import-journeys = journeysCsv: flake-utils.lib.mkApp {
    drv =
      let
        newHeader = "departure_time,return_time,departure_station_id,return_station_id,distance_in_meters";
      in
      pkgs.writeShellScriptBin "import-journeys.sh" ''
        source ${initCurl}

        cat <<EOF | ${pkgs.curl}/bin/curl \
          "''${UPSTREAM}"/journeys \
          --include \
          --header 'Content-Type: text/csv' \
          --data-binary  @-
        ${newHeader}
        $(head -n20 ${journeysCsv} | 
          tail -n+2 |
          cut --complement --fields=4,6,8 --delimiter=, -)
        EOF

      '';
  };
in
{
  apps = {
    import-journeys-05 = import-journeys csvFiles.journeys05-csv;
    import-journeys-06 = import-journeys csvFiles.journeys06-csv;
    import-journeys-07 = import-journeys csvFiles.journeys07-csv;
    import-stations = flake-utils.lib.mkApp {
      drv =
        let
          newHeader = "id,name_fi,name_sv,name_en,address_fi,address_sv,city_fi,city_sv,operator,capacity,x,y";
        in
        pkgs.writeShellScriptBin "import-stations.sh" ''
          source ${initCurl}

          echo ${newHeader}                   | # Csv header with the right column names.
            cat - <(tail -n+2 ${csvFiles.stations-csv} | # Drop the header line of the csv.
            cut --complement -f 1 -d, -)      | # Cut the first column (FID) as it's not used.
            ${pkgs.curl}/bin/curl \
              "''${UPSTREAM}"/stations \
              --include \
              --header 'Content-Type: text/csv' \
              --data-binary  @-
        '';
    };
  };
}
