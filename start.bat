@echo off
setlocal
title CANIRUN PAINEL API - start
cd /d "%~dp0"

set "PORTA=4321"
set "LOG=dev.log"

rem --- ja esta rodando? ---
netstat -ano | findstr ":%PORTA%" | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
  echo.
  echo   O servidor JA esta rodando na porta %PORTA%.
  echo.
  echo     Site:       http://localhost:%PORTA%/
  echo     Playground: http://localhost:%PORTA%/playground
  echo.
  echo   Para parar, use stop.bat
  echo.
  ping -n 4 127.0.0.1 >nul
  exit /b 0
)

where pnpm >nul 2>nul
if errorlevel 1 (
  echo.
  echo   pnpm nao encontrado no PATH.
  echo   Ative com: corepack enable
  echo.
  pause
  exit /b 1
)

if not exist "%~dp0node_modules" (
  echo.
  echo   node_modules nao encontrado. Rode primeiro:
  echo     pnpm install
  echo.
  pause
  exit /b 1
)

if exist "%LOG%" del "%LOG%" >nul 2>&1

echo.
echo   Subindo o CANIRUN em segundo plano...
echo   Log: %CD%\%LOG%
echo.

start "CANIRUN dev" /min cmd /c "pnpm dev > %LOG% 2>&1"

set /a tent=0
:esperar
ping -n 2 127.0.0.1 >nul
set /a tent+=1
netstat -ano | findstr ":%PORTA%" | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 goto pronto
if %tent% lss 90 goto esperar

echo.
echo   AVISO: a porta %PORTA% nao respondeu em ~3 minutos.
echo   Ultimas linhas do %LOG%:
echo.
powershell -NoProfile -Command "if (Test-Path '%LOG%') { Get-Content '%LOG%' -Tail 20 }"
echo.
pause
exit /b 1

:pronto
echo   OK - servidor no ar:
echo.
echo     Site:       http://localhost:%PORTA%/
echo     Playground: http://localhost:%PORTA%/playground
echo.
echo   Para parar, use stop.bat
echo.
ping -n 5 127.0.0.1 >nul
exit /b 0