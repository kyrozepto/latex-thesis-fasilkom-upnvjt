#!/usr/bin/env bash
# Render setiap sumber TikZ di folder ini menjadi PDF vektor di ../figures/.
#
#   bash build.sh                  -> build seluruh berkas .tex
#   bash build.sh example-diagram  -> build satu berkas saja (tanpa ekstensi)
#
# Berkas .aux dan .log hasil antara dihapus setelah build sehingga folder
# ../figures/ hanya berisi berkas gambar.
set -u

cd "$(dirname "$0")"
OUT=../figures

if [ "$#" -gt 0 ]; then
  targets=()
  for name in "$@"; do targets+=("${name%.tex}.tex"); done
else
  # preamble.tex bukan gambar, melainkan berkas yang di-\input berkas lain
  targets=()
  for src in *.tex; do
    [ "$src" = "preamble.tex" ] && continue
    targets+=("$src")
  done
fi

fail=0
for src in "${targets[@]}"; do
  base="${src%.tex}"
  printf '  %-36s ' "$base"
  if pdflatex -interaction=nonstopmode -halt-on-error \
       -output-directory="$OUT" "$src" > /dev/null 2>&1; then
    echo "ok"
  else
    echo "GAGAL -- lihat $OUT/$base.log"
    fail=1
  fi
  rm -f "$OUT/$base.aux"
  [ "$fail" -eq 0 ] && rm -f "$OUT/$base.log"
done

exit "$fail"
