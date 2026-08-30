@echo off
REM Render setiap sumber TikZ di folder ini menjadi PDF vektor di ..\figures\.
REM
REM   build                  -> build seluruh berkas .tex
REM   build example-diagram  -> build satu berkas saja (tanpa ekstensi)
REM
REM Berkas .aux dan .log hasil antara dihapus setelah build sehingga folder
REM ..\figures\ hanya berisi berkas gambar.

setlocal enabledelayedexpansion
cd /d "%~dp0"

set OUT=..\figures
set FAIL=0

if not "%1"=="" (
  call :render "%~n1"
  exit /b %FAIL%
)

REM preamble.tex bukan gambar, melainkan berkas yang di-\input berkas lain
for %%F in (*.tex) do (
  if /i not "%%~nxF"=="preamble.tex" call :render "%%~nF"
)
exit /b %FAIL%

:render
set BASE=%~1
if not exist "%BASE%.tex" (
  echo   %BASE% -- berkas tidak ditemukan
  set FAIL=1
  exit /b 0
)
<nul set /p "=  %BASE% ... "
pdflatex -interaction=nonstopmode -halt-on-error -output-directory="%OUT%" "%BASE%.tex" >nul 2>&1
if errorlevel 1 (
  echo GAGAL -- lihat %OUT%\%BASE%.log
  set FAIL=1
) else (
  echo ok
  if exist "%OUT%\%BASE%.log" del /q "%OUT%\%BASE%.log"
)
if exist "%OUT%\%BASE%.aux" del /q "%OUT%\%BASE%.aux"
exit /b 0
