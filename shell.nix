with import <nixpkgs> { };
mkShell rec {
  name = "neocode";
  buildInputs = [
    lua51Packages.busted
    lua51Packages.luacov
    lua51Packages.luacheck
    nodePackages.prettier
    stylua
    sumneko-lua-language-server
  ];
  shellHook = ''
    export LUA_PATH="$PWD/?.lua;$PWD/lua/?/init.lua;$PWD/lua/?.lua;$LUA_PATH"

    # format and check -> fac :)
    alias fac="prettier --write README.md \
        && stylua lua/ \
        && luacheck lua/ \
        && stylua spec/ \
        && luacheck spec/ \
        && busted --verbose -c"
  '';
}
