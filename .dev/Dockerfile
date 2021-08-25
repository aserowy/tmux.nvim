FROM nixpkgs/nix:latest

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
RUN nix-channel --update

RUN nix-env -iA nixpkgs.git
RUN nix-env -iA nixpkgs.gnugrep
RUN nix-env -iA nixpkgs.neovim
RUN nix-env -iA nixpkgs.ps
RUN nix-env -iA nixpkgs.tmux

RUN mkdir /workspace
VOLUME [ "/workspace" ]

WORKDIR /root
COPY .tmux.conf .
RUN mkdir -p .config/nvim/
COPY init.lua .config/nvim/

ENTRYPOINT [ "/bin/sh" ]
