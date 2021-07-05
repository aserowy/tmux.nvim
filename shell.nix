with import <nixpkgs> { };
mkShell rec {
  name = "neocode";
  buildInputs = [
    cargo
    lua51Packages.busted
    lua51Packages.luacheck
    pkgs.nodePackages.prettier
  ];
  shellHook = ''
    cargo install --root $PWD/.cargo stylua

    PATH=$PWD/.cargo/bin:$PATH
    LUA_PATH=$PWD/lua/?.lua;$LUA_PATH

    # format and check -> fac :)
    alias fac="prettier --write README.md \
        && stylua lua/ \
        && luacheck lua/ \
        && stylua spec/ \
        && luacheck spec/ \
        && busted --verbose"
  '';
}
