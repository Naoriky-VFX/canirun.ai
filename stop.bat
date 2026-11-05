@echo off
setlocal enabledelayedexpansion
title CANIRUN PAINEL API - stop
cd /d "%~dp0"

set "PORTA=4321"
set "ACHOU=0"
set "TMP1=%TEMP%\canirun_pids.txt"

rem --- 1) quem esta escutando na porta 4321 ---
powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort %PORTA% -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique" > "%TMP1%" 2>nul
for /f "usebackq tokens=*" %%P in ("%TMP1%") do (
  if not "%%P"=="" (
    echo   Encerrando servidor - PID %%P
    taskkill /PID %%P /T /F >nul 2>&1
    set "ACHOU=1"
  )
)

rem --- 2) sobras: node/cmd deste projeto rodando "astro dev" ou "pnpm dev" ---
powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { ($_.Name -eq 'node.exe' -or $_.Name -eq 'cmd.exe') -and $_.CommandLine -match 'dev\.log' } | ForEach-Object { $_.ProcessId }" > "%TMP1%" 2>nul
for /f "usebackq tokens=*" %%P in ("%TMP1%") do (
  if not "%%P"=="" (
    echo   Encerrando processo - PID %%P
    taskkill /PID %%P /T /F >nul 2>&1
    set "ACHOU=1"
  )
)

del "%TMP1%" >nul 2>&1

ping -n 3 127.0.0.1 >nul
netstat -ano | findstr ":%PORTA%" | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 (
  echo.
  echo   AVISO: a porta %PORTA% continua em uso.
  echo   Rode o stop.bat de novo ou reinicie o computador.
  echo.
  ping -n 6 127.0.0.1 >nul
  exit /b 1
)

if "!ACHOU!"=="0" (
  echo.
  echo   O servidor nao estava rodando.
  echo.
) else (
  echo.
  echo   Servidor parado.
  echo.
)

ping -n 4 127.0.0.1 >nul
exit /b 0