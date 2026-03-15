#!/usr/bin/env bash
set -euo pipefail

BASE_RESUME="resume.yaml"
PRIVATE_RESUME="secrets/resume.sops.yaml"
VARIANT="${1:-default}"

TMP_DIR="$(mktemp -d ".resume-tmp.XXXXXX")"
DECRYPTED_TMP="$TMP_DIR/resume-decrypted.yaml"
MERGED_TMP="$TMP_DIR/resume-merged.yaml"
FILTERED_TMP="$TMP_DIR/resume-filtered.yaml"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

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
goresume export --pdf -r "$FILTERED_TMP" --pdf-theme professional --pdf-output "$PDF_OUTPUT" --html-output "$HTML_OUTPUT"
