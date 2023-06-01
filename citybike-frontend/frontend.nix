{ pkgs, flake-utils }:
{
  apps =
    let
      envInit = pkgs.writeShellScript "initialize-sqitch-env.sh" ''
        PROJECTPATH=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
        PLANFILE=''${PROJECTPATH}/citybike-backend/sqitch-migrations/sqitch.plan
        source ''${PROJECTPATH}/citybike-backend/.env
      '';
    in
    {
      elm-live = flake-utils.lib.mkApp {
        drv = pkgs.writeShellApplication {
          name = "elm-live.sh";
          runtimeInputs = [ pkgs.elmPackages.elm ];
          text = ''
            PROJECTPATH=$(${pkgs.git}/bin/git rev-parse --show-toplevel)

            # There seems to be no other way than starting elm-live in the same
            # path as elm.json.
            pushd "''${PROJECTPATH}"/citybike-frontend

            ${pkgs.elmPackages.elm-live}/bin/elm-live \
              "''${PROJECTPATH}"/citybike-frontend/src/Main.elm \
              --pushstate \
              --startpage="''${PROJECTPATH}"/citybike-frontend/static/index.html \
              --dir="''${PROJECTPATH}"/citybike-frontend/static \
              -- \
                --output="''${PROJECTPATH}"/citybike-frontend/static/_generated/elm.js \

            popd

          '';
        };
      };
      tailwindcss = flake-utils.lib.mkApp {
        drv = pkgs.writeShellScriptBin "tailwindcss.sh" ''
          PROJECTPATH=$(${pkgs.git}/bin/git rev-parse --show-toplevel)

          # Tailwindcss does not work properly unless run in the root of the
          # frontend.
          pushd ''${PROJECTPATH}/citybike-frontend

          ${pkgs.nodePackages.tailwindcss}/bin/tailwindcss \
            --config=''${PROJECTPATH}/citybike-frontend/tailwindcss/tailwind.config.js \
            --input=''${PROJECTPATH}/citybike-frontend/tailwindcss/input.css \
            --output=''${PROJECTPATH}/citybike-frontend/static/_generated/tailwind.build.css \
            --watch

          popd
        '';
      };
    };
}
