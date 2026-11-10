#!/bin/bash
# Download GGUF weights for DavidAU/Qwen3.5-9B-The-Defiant-Fable-Uncensored-Heretic-NEO-IMATRIX-MAX-MTP-GGUF from HuggingFace.
# Mirror repo contains no weights (GitHub 100MB single-file limit).
# Anonymous download, no token, no credentials: repo is gated=false.
set -euo pipefail
HF_REPO="DavidAU/Qwen3.5-9B-The-Defiant-Fable-Uncensored-Heretic-NEO-IMATRIX-MAX-MTP-GGUF"
BASE="https://huggingface.co/$HF_REPO/resolve/main"
DEFAULT_QUANT="Q4_K_M"

usage() {
  echo "Usage: ./download.sh [QUANT] | ./download.sh --list | ./download.sh --mmproj"
  echo "  Default (no arg): Q4_K_M (6.83GB, 6828993824 bytes)"
  echo "  Example: ./download.sh Q4_K_M"
  echo "  --list: list all available quantizations and sizes"
  echo "  --mmproj: download mmproj file(s) (vision, optional)"
}

list_quants() {
  echo "Available quantizations for $HF_REPO:"
  echo "  IQ2_M                           4.94 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-IQ2_M.gguf"
  echo "  IQ3_M                           5.62 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-IQ3_M.gguf"
  echo "  IQ4_NL                          6.62 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-IQ4_NL.gguf"
  echo "  IQ4_XS                          6.40 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-IQ4_XS.gguf"
  echo "  MTP-IQ2_M                       4.94 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-IQ2_M.gguf"
  echo "  MTP-IQ3_M                       5.72 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-IQ3_M.gguf"
  echo "  MTP-IQ4_NL                      6.76 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-IQ4_NL.gguf"
  echo "  MTP-IQ4_XS                      6.53 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-IQ4_XS.gguf"
  echo "  MTP-Q4_K_M                      6.98 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-Q4_K_M.gguf"
  echo "  MTP-Q4_K_S                      6.69 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-Q4_K_S.gguf"
  echo "  MTP-Q5_K_M                      7.84 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-Q5_K_M.gguf"
  echo "  MTP-Q5_K_S                      7.67 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-Q5_K_S.gguf"
  echo "  MTP-Q6_K                        8.76 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-Q6_K.gguf"
  echo "  MTP-Q8_0                       10.74 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-Q8_0.gguf"
  echo "  Q4_K_M                          6.83 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-Q4_K_M.gguf"
  echo "  Q4_K_S                          6.55 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-Q4_K_S.gguf"
  echo "  Q5_K_M                          7.67 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-Q5_K_M.gguf"
  echo "  Q5_K_S                          7.51 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-Q5_K_S.gguf"
  echo "  Q6_K                            8.56 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-Q6_K.gguf"
  echo "  Q8_0                           10.48 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-Q8_0.gguf"
  echo "  plusIQ-MTP-Q6_K                 8.76 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-plusIQ-NEO-MAX-MTP-Q6_K.gguf"
  echo "  plusIQ-MTP-Q8_0                10.74 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-plusIQ-NEO-MAX-MTP-Q8_0.gguf"
  echo "  plusIQ-MTP-bf16                18.41 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-plusIQ-NEO-MAX-MTP-bf16.gguf"
  echo "  plusIQ-TOOLS-MTP-Q6_K           8.76 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-plusIQ-TOOLS-NEO-MAX-MTP-Q6_K.gguf"
  echo "  plusIQ-TOOLS-MTP-Q8_0          10.74 GB  Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-plusIQ-TOOLS-NEO-MAX-MTP-Q8_0.gguf"
  echo "mmproj (optional, --mmproj):"
  echo "  mmproj    0.92 GB  mmproj-BF16.gguf"
  echo "  mmproj    0.92 GB  mmproj-F16.gguf"
  echo "  mmproj    1.82 GB  mmproj-F32.gguf"
}

download_one() {
  file="$1"; size="$2"; sha="$3"
  echo "Downloading $file ($size bytes, sha256 $sha) ..."
  echo "Make sure you have enough disk space (total for this file: $size bytes)."
  tmp="$file.tmp"
  curl -L --fail --retry 3 -o "$tmp" "$BASE/$file" || { rm -f "$tmp"; echo "ERROR: download failed: $file" >&2; exit 1; }
  got=$(wc -c < "$tmp" | tr -d ' ')
  if [ "$got" != "$size" ]; then echo "ERROR: size mismatch for $file: got $got, expected $size" >&2; rm -f "$tmp"; exit 1; fi
  if command -v sha256sum >/dev/null 2>&1; then
    actual=$(sha256sum "$tmp" | cut -d' ' -f1)
  elif command -v shasum >/dev/null 2>&1; then
    actual=$(shasum -a 256 "$tmp" | cut -d' ' -f1)
  else
    echo "WARNING: no sha256 tool found, skipping sha256 check for $file" >&2; actual="$sha"
  fi
  if [ "$actual" != "$sha" ]; then echo "ERROR: sha256 mismatch for $file: got $actual, expected $sha" >&2; rm -f "$tmp"; exit 1; fi
  mv "$tmp" "$file"
  echo "OK: $file ($size bytes, sha256 verified)"
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then usage; exit 0; fi
if [ "${1:-}" = "--list" ]; then list_quants; exit 0; fi
if [ "${1:-}" = "--mmproj" ]; then
  total=0
  total=$((total + 921705024))
  total=$((total + 918166080))
  total=$((total + 1824062016))
  echo "mmproj total: $total bytes. Make sure you have enough disk space."
  download_one "mmproj-BF16.gguf" 921705024 853698ce7aa6c7ba732478bad280240969ddf7b0fcbf93900046f63903a83383
  download_one "mmproj-F16.gguf" 918166080 f70dc3509053962b0d0d3ee8a7eacebf5d60aa560cad78254ae8698516ae029f
  download_one "mmproj-F32.gguf" 1824062016 a1cd5c1625b44dd0facaec998020e9b36cb78c2225eaee701e73bf2e5b051ce2
  echo "All mmproj files downloaded and verified."
  exit 0
fi

QUANT="${1:-$DEFAULT_QUANT}"
case "$QUANT" in
    IQ2_M)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-IQ2_M.gguf"
      SIZES="4942441760"
      SHAS="ae9679dee69a4cb3a9375efa3644adc0164a362c61df2b283696d05e57df2fca"
      ;;
    IQ3_M)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-IQ3_M.gguf"
      SIZES="5615267104"
      SHAS="88cce3a5c2793a801e1c3f9b7ec4eaaa8d4c68ad2017718b517b6d019281eaea"
      ;;
    IQ4_NL)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-IQ4_NL.gguf"
      SIZES="6618098976"
      SHAS="fc98be8168f39ed159f65c6fd193e803ae5ac1a774b738654811db1244103360"
      ;;
    IQ4_XS)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-IQ4_XS.gguf"
      SIZES="6396325152"
      SHAS="a5a35852c81f2c677c9cac813335add3be46328b66d517d94db84b76308b6217"
      ;;
    MTP-IQ2_M)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-IQ2_M.gguf"
      SIZES="4942442720"
      SHAS="3349c656c2b16659a230a8d92acf0c55c2ae41876747deb5ba04a76a5a31a004"
      ;;
    MTP-IQ3_M)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-IQ3_M.gguf"
      SIZES="5722667232"
      SHAS="726ad4c6c41906e314052e69a294ae3372310c8d11c2e78d4e97784d5beec110"
      ;;
    MTP-IQ4_NL)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-IQ4_NL.gguf"
      SIZES="6755547360"
      SHAS="c46c85c3e2d0c4d6ab62f5d7bb944739c0fd52fea8b04f786434a4358fa49def"
      ;;
    MTP-IQ4_XS)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-IQ4_XS.gguf"
      SIZES="6526302432"
      SHAS="8d33af536e35805967c9f4d77e1ed62b8212bdee282c80c6dc9b79ae6d677637"
      ;;
    MTP-Q4_K_M)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-Q4_K_M.gguf"
      SIZES="6979975392"
      SHAS="d7eb4fac9389d53fa576f64a6ff53e914a00bc7705dc354d1065887565147320"
      ;;
    MTP-Q4_K_S)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-Q4_K_S.gguf"
      SIZES="6688438496"
      SHAS="1899fa1c7427db6f3e87f4b215a42a5101eec21eab7fd2cea5a658aad50dc2e1"
      ;;
    MTP-Q5_K_M)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-Q5_K_M.gguf"
      SIZES="7842429152"
      SHAS="a78b01d87e54c85191b7d139f229c5cdb5e9c9af08d832accd14b3b5fd1c3f6d"
      ;;
    MTP-Q5_K_S)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-Q5_K_S.gguf"
      SIZES="7672527072"
      SHAS="bf2e8adeb558711630e241d72b0ec0ff0f2de1af0e8764e5f9b8b2ccfb32826e"
      ;;
    MTP-Q6_K)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-Q6_K.gguf"
      SIZES="8758786272"
      SHAS="b54d045cc07cc48259a2329f2b86ba8956de15a44d71d5004a6f8598d71c36d6"
      ;;
    MTP-Q8_0)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-MTP-Q8_0.gguf"
      SIZES="10739611872"
      SHAS="1830f3beffb43850143bf45ee6f9d637f82ca22ddd9e08e40be1399062be32a2"
      ;;
    Q4_K_M)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-Q4_K_M.gguf"
      SIZES="6828993824"
      SHAS="d33db5e583b9c9251402e876443791bc979f12af934bfb0630eadfb456279f84"
      ;;
    Q4_K_S)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-Q4_K_S.gguf"
      SIZES="6551514400"
      SHAS="6d738a564822d8ad0f0f3b4cae135e66c90ef0f5e30ed1722c79817802e2b62b"
      ;;
    Q5_K_M)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-Q5_K_M.gguf"
      SIZES="7667854624"
      SHAS="3138b1069d7a798460eba9cedf7b865f4dbf285b43117d9db549d124797cebbf"
      ;;
    Q5_K_S)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-Q5_K_S.gguf"
      SIZES="7505194272"
      SHAS="282eda65148f468154ea21ebc5e39ab1f1dce898c597640ceccfc47ecc139131"
      ;;
    Q6_K)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-Q6_K.gguf"
      SIZES="8559144224"
      SHAS="be2e829c3cb38fc98ec53ee25311a4fa6a8437463f974fded6ce1c052c3cd643"
      ;;
    Q8_0)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-NEO-MAX-Q8_0.gguf"
      SIZES="10481052960"
      SHAS="a0ed28f9af669f48ff2138f1f016bda3f1b3daf305cc3bb9c501f4c6b48e48a5"
      ;;
    plusIQ-MTP-Q6_K)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-plusIQ-NEO-MAX-MTP-Q6_K.gguf"
      SIZES="8758792960"
      SHAS="824188550771077e8ae1131d4d4826d08f79dab862d2c5725d4506931b80e9a1"
      ;;
    plusIQ-MTP-Q8_0)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-plusIQ-NEO-MAX-MTP-Q8_0.gguf"
      SIZES="10739618560"
      SHAS="dcabfc7ab12fac26f84adb061e99eee793837c1cf1bb432a27b8790f7a91f14e"
      ;;
    plusIQ-MTP-bf16)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-plusIQ-NEO-MAX-MTP-bf16.gguf"
      SIZES="18407330272"
      SHAS="6a772118b107772fb83d111fec59e54b139c993fe6dc4906288a3bb81178705d"
      ;;
    plusIQ-TOOLS-MTP-Q6_K)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-plusIQ-TOOLS-NEO-MAX-MTP-Q6_K.gguf"
      SIZES="8758814912"
      SHAS="2e8be304734e365f6b77f95f255f7cbc3aa46dd112d4169f1ea5a42266e6ef76"
      ;;
    plusIQ-TOOLS-MTP-Q8_0)
      FILES="Qwen3.5-9B-The-Defiant-Fable-Uncnr-Heretic-plusIQ-TOOLS-NEO-MAX-MTP-Q8_0.gguf"
      SIZES="10739640512"
      SHAS="701fd92f14cb7752923ecef608e1a5c5f6281affeb3dea6fc73b1b505c1c71a9"
      ;;
  *)
    echo "ERROR: unknown quantization: $QUANT" >&2
    list_quants
    exit 1
    ;;
esac

# Total size / disk-space reminder before downloading
echo "Quantization: $QUANT"
echo "Total download size: $SIZES bytes. Make sure you have enough disk space."
set -- $FILES
i=1
for f in $FILES; do
  sz=$(echo "$SIZES" | cut -d' ' -f"$i")
  sh=$(echo "$SHAS" | cut -d' ' -f"$i")
  download_one "$f" "$sz" "$sh"
  i=$((i + 1))
done
echo "Done. Downloaded and verified: $FILES"
