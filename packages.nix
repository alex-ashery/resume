{ pkgs }:
let
  goresume = pkgs.stdenvNoCC.mkDerivation {
    pname = "goresume";
    version = "0.3.21";

    src = pkgs.fetchurl {
      url = "https://github.com/nikaro/goresume/releases/download/0.3.21/goresume_0.3.21_darwin_arm64.tar.gz";
      hash = "sha256-Sga8QRr/M8EQAk/CNStX9a4wdK+S+pbdgW40XXYd7uA=";
    };

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      runHook preUnpack
      mkdir -p source
      tar -xzf "$src" -C source
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"

      bin_path="$(find source -type f -name goresume -perm -u+x | head -n1)"
      if [ -z "$bin_path" ]; then
        echo "goresume binary not found in archive"
        exit 1
      fi

      install -m755 "$bin_path" "$out/bin/goresume"
      runHook postInstall
    '';
  };
in
with pkgs; [
  just
  yq-go
  goresume
  sops
]
