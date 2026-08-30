#!/usr/bin/env bash
# Build LaTeX targets (pdflatex -> bibtex -> pdflatex -> pdflatex).
# POSIX twin of build.bat, for Linux, macOS, and WSL. Same targets, same passes.
#
# Four passes are needed: pass 1 collects labels and citations, bibtex turns the
# citations into a .bbl, pass 3 typesets the bibliography, and pass 4 settles the
# page numbers that the new bibliography pages shifted.
#
# Usage:
#   ./build.sh            -> proposal (default)
#   ./build.sh proposal   -> proposal.tex       Bab I-III
#   ./build.sh draft      -> skripsi-draft.tex  Bab I-IV
#   ./build.sh skripsi    -> main.tex           Bab I-V, naskah akhir
#   ./build.sh main       -> alias of "skripsi"
#   ./build.sh all        -> all three
#   ./build.sh clean      -> remove aux files (keeps PDFs)
set -u

cd "$(dirname "$0")"

OPTS="-interaction=nonstopmode -halt-on-error -file-line-error"
TARGETS="proposal skripsi-draft main"
# .loa belongs to algorithm2e (Daftar Algoritma) and .lap to the template's own
# Daftar Lampiran. Both have to go, or a stale list survives the rebuild.
EXTS="aux bbl blg fdb_latexmk fls lof log lot loa lap out toc"

build() {
  echo "=== Building $1.tex ==="

  echo "[1/4] pdflatex"
  pdflatex $OPTS "$1.tex" >/dev/null || { failed "$1"; return 1; }

  echo "[2/4] bibtex"
  # A manuscript without a single \cite makes bibtex exit non-zero. That is not
  # a build failure, so the step only warns.
  bibtex "$1" >/dev/null || echo "NOTE: bibtex reported a problem, see $1.blg"

  echo "[3/4] pdflatex"
  pdflatex $OPTS "$1.tex" >/dev/null || { failed "$1"; return 1; }

  echo "[4/4] pdflatex"
  pdflatex $OPTS "$1.tex" >/dev/null || { failed "$1"; return 1; }

  echo "OK: $1.pdf"
  if grep -q "LaTeX Warning: There were undefined references" "$1.log"; then
    echo "NOTE: undefined references remain in $1.log"
  fi
}

failed() {
  echo
  echo "BUILD FAILED: $1.tex"
  echo "Last errors from $1.log:"
  grep -E "^.*:[0-9]+:" "$1.log" || true
}

target="${1:-proposal}"

case "$target" in
  clean)
    for t in $TARGETS; do
      for e in $EXTS; do rm -f "$t.$e"; done
    done
    echo "Cleaned aux files."
    exit 0
    ;;
  all)
    for t in $TARGETS; do build "$t" || exit 1; done
    exit 0
    ;;
  draft)   target=skripsi-draft ;;
  skripsi) target=main ;;
esac

if [ ! -f "$target.tex" ]; then
  echo "Unknown target \"$1\"."
  echo "Valid targets: proposal, draft, skripsi, all, clean"
  exit 1
fi

build "$target"
