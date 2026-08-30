@echo off
REM Build LaTeX targets (pdflatex -> bibtex -> pdflatex -> pdflatex).
REM Four passes are needed: pass 1 collects labels and citations, bibtex turns
REM the citations into a .bbl, pass 3 typesets the bibliography, and pass 4
REM settles the page numbers that the new bibliography pages shifted.
REM
REM latexmk is NOT used: a MiKTeX installation usually has no perl script engine.
REM
REM Usage:
REM   build            -> proposal (default)
REM   build proposal   -> proposal.tex       Bab I-III
REM   build draft      -> skripsi-draft.tex  Bab I-IV
REM   build skripsi    -> main.tex           Bab I-V, naskah akhir
REM   build main       -> alias of "build skripsi"
REM   build all        -> all three
REM   build clean      -> remove aux files (keeps PDFs)

setlocal
cd /d "%~dp0"

set TARGET=%1
if "%TARGET%"=="" set TARGET=proposal

if /i "%TARGET%"=="clean"   goto :clean
if /i "%TARGET%"=="all"     goto :all
if /i "%TARGET%"=="draft"   set TARGET=skripsi-draft
if /i "%TARGET%"=="skripsi" set TARGET=main

if not exist "%TARGET%.tex" (
  echo Unknown target "%1".
  echo Valid targets: proposal, draft, skripsi, all, clean
  exit /b 1
)

call :build %TARGET%
exit /b %ERRORLEVEL%

:all
call :build proposal       || exit /b 1
call :build skripsi-draft  || exit /b 1
call :build main           || exit /b 1
exit /b 0

:clean
REM .loa belongs to algorithm2e (Daftar Algoritma) and .lap to the template's
REM own Daftar Lampiran. Both have to go, or a stale list survives the rebuild.
for %%T in (proposal skripsi-draft main) do (
  for %%E in (aux bbl blg fdb_latexmk fls lof log lot loa lap out toc) do (
    if exist "%%T.%%E" del /q "%%T.%%E"
  )
)
echo Cleaned aux files.
exit /b 0

:build
echo === Building %1.tex ===
set OPTS=-interaction=nonstopmode -halt-on-error -file-line-error

echo [1/4] pdflatex
pdflatex %OPTS% "%1.tex" >nul || goto :failed

echo [2/4] bibtex
REM A manuscript without a single \cite makes bibtex exit non-zero. That is not
REM a build failure, so the step only warns.
bibtex "%1" >nul || echo NOTE: bibtex reported a problem, see %1.blg

echo [3/4] pdflatex
pdflatex %OPTS% "%1.tex" >nul || goto :failed

echo [4/4] pdflatex
pdflatex %OPTS% "%1.tex" >nul || goto :failed

echo OK: %1.pdf
findstr /c:"LaTeX Warning: There were undefined references" "%1.log" >nul && echo NOTE: undefined references remain in %1.log
exit /b 0

:failed
echo.
echo BUILD FAILED: %1.tex
echo Last errors from %1.log:
findstr /r /c:"^.*:[0-9][0-9]*:" "%1.log"
exit /b 1
