{ pkgs }:
with pkgs; [
  go
  just
  yq-go
  sops
  cspell
  pre-commit
]
