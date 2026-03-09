#!/usr/bin/env bash
set -euo pipefail

BASE_RESUME="resume.yaml"
PRIVATE_RESUME="secrets/resume.sops.yaml"

TMP_DIR="$(mktemp -d ".resume-tmp.XXXXXX")"
DECRYPTED_TMP="$TMP_DIR/resume-decrypted.yaml"
MERGED_TMP="$TMP_DIR/resume-merged.yaml"

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

mkdir -p rendered
goresume export --pdf -r "$MERGED_TMP" --pdf-theme professional --pdf-output rendered/resume.pdf --html-output rendered/resume.html
