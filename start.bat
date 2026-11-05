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
  echo     Site:       http://localhost:%PORTA%/
  echo     Playground: http://localhost:%PORTA%/playground
  echo   Para parar, use stop.bat
  echo.
  exit /b 0
)

if exist "%LOG%" del "%LOG%" >nul 2>&1

where pnpm >nul 2>nul
if errorlevel 1 (
  echo [start.bat] ERRO: pnpm nao encontrado no PATH. Ative com: corepack enable >> "%LOG%"
  echo.
  echo   ERRO: pnpm nao encontrado no PATH - veja %LOG%
  echo.
  exit /b 1
)

if not exist "%~dp0node_modules" (
  echo [start.bat] ERRO: node_modules nao encontrado. Rode: pnpm install >> "%LOG%"
  echo.
  echo   ERRO: node_modules nao encontrado - veja %LOG%
  echo.
  exit /b 1
)

echo.
echo   Subindo o CANIRUN em segundo plano (sem janela)...
echo   Log: %CD%\%LOG%
echo.

rem --- sobe o servidor SEM janela; toda a saida vai para dev.log ---
powershell -NoProfile -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','pnpm dev > dev.log 2>&1' -WorkingDirectory '%CD%' -WindowStyle Hidden"

set /a tent=0
:esperar
ping -n 2 127.0.0.1 >nul
set /a tent+=1
netstat -ano | findstr ":%PORTA%" | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 goto pronto
if %tent% lss 90 goto esperar

echo [start.bat] ERRO: a porta %PORTA% nao respondeu em ~3 minutos. >> "%LOG%"
echo.
echo   ERRO: a porta %PORTA% nao respondeu em ~3 minutos - veja %LOG%
echo.
exit /b 1

:pronto
echo   OK - servidor no ar:
echo.
echo     Site:       http://localhost:%PORTA%/
echo     Playground: http://localhost:%PORTA%/playground
echo.
echo   Para parar, use stop.bat
echo.
exit /b 0