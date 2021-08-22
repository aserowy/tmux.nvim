FROM nixos/nix

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
RUN nix-channel --update

RUN mkdir /workspace
VOLUME [ "/workspace" ]

WORKDIR /root
ADD .tmux.conf .
RUN mkdir -p .config/nvim/
ADD init.lua .config/nvim/

ENTRYPOINT [ "/bin/sh" ]
