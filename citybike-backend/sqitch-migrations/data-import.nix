{ pkgs, flake-utils, csvFiles, ... }:
let
  setEnvironment = pkgs.writeShellScript "init-curl.sh" ''
    PROJECTPATH=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
    source ''${PROJECTPATH}/citybike-backend/.env
    UPSTREAM=''${PGRST_UPSTREAM}:''${DEV_PGRST_PORT}
  '';

  import-stations = flake-utils.lib.mkApp {
    drv =
      let
        clean-stations =
          pkgs.writers.writePython3
            "clean_stations.py"
            { libraries = with pkgs.python3Packages; [ pandas ]; }
            ./clean_stations.py;
        newHeader = "id,name_fi,name_sv,name_en,address_fi,address_sv,city_fi,city_sv,operator,capacity,x,y";
      in
      pkgs.writeShellScriptBin "import-stations.sh" ''
        source ${setEnvironment}

        echo ${newHeader} | # Csv header with the right column names.
          cat - <(tail -n+2 <(${clean-stations} ${csvFiles.stations-csv}) | # Drop the header line of the csv.
          cut --complement -f 1 -d, -) | # Cut the first column (FID) as it's not used.
          ${pkgs.curl}/bin/curl \
            "''${UPSTREAM}"/stations \
            --include \
            --header 'Content-Type: text/csv' \
            --data-binary  @-
      '';
  };

  import-journeys = journeysCsv: flake-utils.lib.mkApp {
    drv =
      let
        clean-journeys = pkgs.writers.writePython3
          "clean_journeys.py"
          { libraries = with pkgs.python3Packages; [ pandas requests ]; }
          ./clean_journeys.py;
        newHeader = "departure_time,return_time,departure_station_id,return_station_id,distance_in_meters";
      in
      pkgs.writeShellScriptBin "import-journeys.sh" ''
        source ${setEnvironment}

        
        ${clean-journeys} --api ''${UPSTREAM} ${journeysCsv} | 
          ${pkgs.curl}/bin/curl \
          "''${UPSTREAM}"/journeys \
          --include \
          --header 'Content-Type: text/csv' \
          --verbose \
          --data-binary  @-

        # cat <<EOF > tmp.txt
        # Departure,Return,Departure station id,Departure station name,Return station id,Return station name,Covered distance (m),Duration (sec.)
        # 2021-07-31T23:56:56,2021-08-01T00:14:07,161,Eteläesplanadi,031,Marian sairaala,2289,1027
        # 2021-07-31T23:56:51,2021-08-01T00:21:34,120,Mäkelänkatu,094,Laajalahden aukio,5646,1479
        # 2021-07-31T23:56:48,2021-08-01T00:03:53,116,Linnanmäki,113,Pasilan asema,1080,422
        # 2021-07-31T23:56:38,2021-08-01T00:14:58,131,Elimäenkatu,035,Cygnaeuksenkatu,3755,1096
        # EOF
        # ${clean-journeys} --api ''${UPSTREAM} tmp.txt
        # cat <<EOF | ${pkgs.curl}/bin/curl \
        #   "''${UPSTREAM}"/journeys \
        #   --include \
        #   --header 'Content-Type: text/csv' \
        #   --verbose \
        #   --data-binary  @-
        # ${newHeader}
        # $(${clean-journeys} --api ''${UPSTREAM} ${journeysCsv} | 
        #   tail -n+2 |
        #   cut --complement --fields=4,6,8 --delimiter=, -)
        # EOF

      '';
  };
in
{
  apps = {
    import-stations = import-stations;
    import-journeys-05 = import-journeys csvFiles.journeys05-csv;
    import-journeys-06 = import-journeys csvFiles.journeys06-csv;
    import-journeys-07 = import-journeys csvFiles.journeys07-csv;
  };
}
