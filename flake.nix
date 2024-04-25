{
  description = "tmux.nvim env";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      with pkgs; {
        devShell =
          pkgs.mkShell {
            buildInputs = [
              gh
              lua51Packages.busted
              lua51Packages.luacov
              lua51Packages.luacheck
              nixpkgs-fmt
              nodePackages.dockerfile-language-server-nodejs
              nodePackages.markdownlint-cli
              nodePackages.prettier
              shfmt
              stylua
              sumneko-lua-language-server
            ];
            shellHook = ''
              export LUA_PATH="$PWD/?.lua;$PWD/lua/?/init.lua;$PWD/lua/?.lua;$LUA_PATH"

              FULLPATH=$(realpath $0)
              BASEDIR=$(dirname $FULLPATH)

              # test environment
              alias tb="docker build -t tmnv-te $BASEDIR/.dev"
              alias te="docker run -it -v $BASEDIR:/workspace tmnv-te"

              # format and check -> fac :)
              alias fac="prettier --write README.md \
                  && stylua .dev/ \
                  && luacheck .dev/ \
                  && stylua lua/ \
                  && luacheck lua/ \
                  && stylua spec/ \
                  && luacheck spec/ \
                  && busted --verbose -c"
            '';
          };
      });
}
