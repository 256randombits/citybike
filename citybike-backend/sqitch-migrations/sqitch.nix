{ pkgs, flake-utils }:
{
  apps =
    let
      # TODO: Conf could be added here. Does not seem to work. Maybe a bug in Sqitch?
      # https://github.com/sqitchers/sqitch/issues/675 might be relevant.
      # These seem to be not respected:
      # SQITCH_CONFIG=${sqitchConf}
      # SQITCH_TARGET=db:pg://''${POSTGRES_USER}:''${POSTGRES_PASSWORD}@''${POSTGRES_SERVER_URL}:''${POSTGRES_PORT}/''${POSTGRES_DB}
      # sqitchConf = pkgs.writeText "sqitch.conf" ''
      #   [core]
      #   	engine = pg
      # '';
      # For now just use the sqitch.conf file in the directory and add flags to sqitch calls.
      # This sucks because now the commands have to be run from the sqitch-migrations directory.
      # A dirty hack would be to pushd and popd. Move on for now.

      sqitchInit = pkgs.writeShellScript "initialize-sqitch-env.sh" ''
        PROJECTPATH=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
        PLANFILE=''${PROJECTPATH}/citybike-backend/sqitch-migrations/sqitch.plan
        source ''${PROJECTPATH}/citybike-backend/.env
      '';
    in
    {
      deploy = flake-utils.lib.mkApp {
        drv = pkgs.writeShellScriptBin "sqitch-deploy" ''
          source ${sqitchInit}

          ${pkgs.sqitchPg}/bin/sqitch deploy \
            --client ${pkgs.postgresql_15}/bin/psql \
            --plan-file ''${PLANFILE} \
            --target db:pg://''${POSTGRES_USER}:''${POSTGRES_PASSWORD}@''${POSTGRES_SERVER_URL}:''${POSTGRES_PORT}/''${POSTGRES_DB} \
            --verify
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
