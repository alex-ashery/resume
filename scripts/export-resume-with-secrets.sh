#!/usr/bin/env bash
set -euo pipefail

BASE_RESUME="resume.yaml"
PRIVATE_RESUME="secrets/resume.sops.yaml"
VARIANT="${1:-default}"
GORESUME_SRC="forks/goresume"

TMP_DIR="$(mktemp -d ".resume-tmp.XXXXXX")"
TMP_DIR="$(cd "$TMP_DIR" && pwd)"
ROOT_DIR="$(pwd)"
DECRYPTED_TMP="$TMP_DIR/resume-decrypted.yaml"
MERGED_TMP="$TMP_DIR/resume-merged.yaml"
FILTERED_TMP="$TMP_DIR/resume-filtered.yaml"
GORESUME_BIN="$TMP_DIR/goresume"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

if [ -d "$GORESUME_SRC" ]; then
  if ! command -v go >/dev/null 2>&1; then
    echo "go is required to build the local goresume fork in $GORESUME_SRC" >&2
    exit 1
  fi
  (
    cd "$GORESUME_SRC"
    go build -o "$GORESUME_BIN" .
  )
else
  GORESUME_BIN="$(command -v goresume)"
fi

sops decrypt "$PRIVATE_RESUME" > "$DECRYPTED_TMP"
if yq --help 2>&1 | grep -q "eval-all"; then
  yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' "$BASE_RESUME" "$DECRYPTED_TMP" > "$MERGED_TMP"
else
  yq -y -s '.[0] * .[1]' "$BASE_RESUME" "$DECRYPTED_TMP" > "$MERGED_TMP"
fi

case "$VARIANT" in
  default)
    cp "$MERGED_TMP" "$FILTERED_TMP"
    PDF_OUTPUT="rendered/resume.pdf"
    HTML_OUTPUT="rendered/resume.html"
    ;;
  observability)
    yq eval '(.work[] | select(.name == "Block, Inc.") | .highlights) |= [.[1], .[2], .[3], .[4], .[5]]' "$MERGED_TMP" > "$FILTERED_TMP"
    PDF_OUTPUT="rendered/resume-observability.pdf"
    HTML_OUTPUT="rendered/resume-observability.html"
    ;;
  platform)
    yq eval '(.work[] | select(.name == "Block, Inc.") | .highlights) |= [.[0], .[1], .[2], .[3], .[4]]' "$MERGED_TMP" > "$FILTERED_TMP"
    PDF_OUTPUT="rendered/resume-platform.pdf"
    HTML_OUTPUT="rendered/resume-platform.html"
    ;;
  *)
    echo "Unknown resume variant: $VARIANT" >&2
    echo "Expected one of: default, observability, platform" >&2
    exit 1
    ;;
esac

mkdir -p rendered
FILTERED_RESUME_ARG="${FILTERED_TMP#"$ROOT_DIR"/}"
"$GORESUME_BIN" export --pdf -r "$FILTERED_RESUME_ARG" --pdf-theme professional --pdf-output "$PDF_OUTPUT" --html-output "$HTML_OUTPUT"
