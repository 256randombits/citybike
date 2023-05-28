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
      in
      pkgs.writeShellScriptBin "import-stations.sh" ''
        source ${setEnvironment}

        ${clean-stations} ${csvFiles.stations-csv} |
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
      '';
  };
in
{
  apps = rec {
    import-stations-all = import-stations;
    import-journeys-05 = import-journeys csvFiles.journeys05-csv;
    import-journeys-06 = import-journeys csvFiles.journeys06-csv;
    import-journeys-07 = import-journeys csvFiles.journeys07-csv;
    # TODO: Maybe create a target which limits the count of the journeys
    # for development purposes
    # import-journeys-dev =
    import-journeys-all = flake-utils.lib.mkApp {
      drv =
        pkgs.writeShellScriptBin "import-journeys-all.sh" ''
          ${import-journeys-05.program}
          ${import-journeys-06.program}
          ${import-journeys-07.program}
        '';
    };
  };
}
