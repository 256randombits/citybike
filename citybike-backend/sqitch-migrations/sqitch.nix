{ pkgs, flake-utils }:
let
  envFileLocation = "citybike-backend/.env";
in
{
  apps = let
    sqitchInit = pkgs.writeShellScript "initialize-sqitch-env.sh" ''
        PROJECTPATH=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
        PLANFILE=''${PROJECTPATH}/citybike-backend/sqitch-migrations/sqitch.plan
        SQITCH_CONFIG=''${PROJECTPATH}/citybike-backend/sqitch-migrations/sqitch.conf
        source ''${PROJECTPATH}/citybike-backend/.env
      '';
  in{
    deploy = flake-utils.lib.mkApp {
      drv = pkgs.writeShellScriptBin "sqitch-deploy" ''
        source ${sqitchInit}

        ${pkgs.sqitchPg}/bin/sqitch deploy \
          --client ${pkgs.postgresql_15}/bin/psql \
          --plan-file ''${PLANFILE} \
          --verify \
          --target db:pg://''${POSTGRES_USER}:''${POSTGRES_PASSWORD}@''${POSTGRES_SERVER_URL}:''${POSTGRES_PORT}/''${POSTGRES_DB}
      '';
    };
    revert = flake-utils.lib.mkApp {
      drv = pkgs.writeShellScriptBin "sqitch-revert" ''
        source ${sqitchInit}

        ${pkgs.sqitchPg}/bin/sqitch revert \
          --client ${pkgs.postgresql_15}/bin/psql \
          --plan-file ''${PLANFILE} \
          --target db:pg://''${POSTGRES_USER}:''${POSTGRES_PASSWORD}@''${POSTGRES_SERVER_URL}:''${POSTGRES_PORT}/''${POSTGRES_DB}
      '';
    };
    add = flake-utils.lib.mkApp {
      drv = pkgs.writeShellScriptBin "sqitch-add" ''
        source ${sqitchInit}

        ${pkgs.sqitchPg}/bin/sqitch add \
          --plan-file ''${PLANFILE} \
          ''$@
      '';
    };
  };
}
