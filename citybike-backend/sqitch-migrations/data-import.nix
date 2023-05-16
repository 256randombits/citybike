{ pkgs, flake-utils, csvFiles, ... }:
let
  initCurl = pkgs.writeShellScript "init-curl.sh" ''
    PROJECTPATH=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
    source ''${PROJECTPATH}/citybike-backend/.env
    UPSTREAM=''${PGRST_UPSTREAM}:''${DEV_PGRST_PORT}
  '';
in
{
  apps = {
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
              -i \
              -H 'Content-Type: text/csv' \
              --data-binary  @-
        '';
    };
  };
}
