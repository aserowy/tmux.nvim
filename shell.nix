with import <nixpkgs> { };
mkShell rec {
  name = "neocode";
  buildInputs = [
    cargo
    lua51Packages.luacheck
  ];
  shellHook = ''
    cargo install --root $PWD/.cargo stylua

    PATH=$PWD/.cargo/bin:$PATH

    # format and check -> fac :)
    alias fac="stylua lua/ && luacheck lua/"
  '';
}
