@echo off
setlocal EnableDelayedExpansion
title FarmaSys POS — Asistente de Instalacion y Actualizacion Oficial (Windows)

:: ============================================================================
:: ELEVACIÓN AUTOMÁTICA A ADMINISTRADOR (Requerido para Firewall y Accesos)
:: ============================================================================
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [i] Solicitando permisos de Administrador para configurar accesos y Firewall...
    powershell -Command "Start-Process -FilePath '%~f0' -ArgumentList '%*' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
color 0B
cls

echo ==============================================================================
echo                      FARMASYS POS — SISTEMA DE COBRO                          
echo               Instalador Oficial de Mostrador de Farmacia                    
echo                     Arquitectura Multi-Sucursal                              
echo ==============================================================================
echo.
echo Bienvenido al asistente oficial de FarmaSys POS.
echo Este asistente permite instalar de cero o actualizar el sistema de cobro,
echo inventario, alertas de vencimiento, reportes comparativos e impresion termica.
echo.
echo NOTA DE SEGURIDAD:
echo Si ya tiene una instalacion previa, sus ventas, inventarios y configuraciones
echo se preservaran intactas. El instalador creara un respaldo preventivo automatico.
echo.
echo ==============================================================================
echo.

set "UNATTENDED=0"
set "TARGET_DIR=C:\FarmaSys_POS"
set "AUTOSTART_FLAG=0"
set "LAUNCH_FLAG=1"

:parse_args
if "%~1"=="" goto end_args
if /i "%~1"=="-TargetDir" (
    set "TARGET_DIR=%~2"
    set "UNATTENDED=1"
    shift
    shift
    goto parse_args
)
if /i "%~1"=="-AutoStart" (
    set "AUTOSTART_FLAG=%~2"
    set "UNATTENDED=1"
    shift
    shift
    goto parse_args
)
if /i "%~1"=="-LaunchNow" (
    set "LAUNCH_FLAG=%~2"
    set "UNATTENDED=1"
    shift
    shift
    goto parse_args
)
if /i "%~1"=="/SILENT" (
    set "UNATTENDED=1"
    shift
    goto parse_args
)
shift
goto parse_args

:end_args

if "!UNATTENDED!"=="0" (
    set /p USER_DIR="1. Directorio de instalacion [Presione ENTER para C:\FarmaSys_POS]: "
    if not "!USER_DIR!"=="" set "TARGET_DIR=!USER_DIR!"

    set /p USER_AUTO="2. Desea iniciar FarmaSys automaticamente al encender la PC? (S/N) [S]: "
    if /i "!USER_AUTO!"=="N" (
        set "AUTOSTART_FLAG=0"
    ) else (
        set "AUTOSTART_FLAG=1"
    )

    set /p USER_LAUNCH="3. Desea abrir el mostrador POS inmediatamente al terminar? (S/N) [S]: "
    if /i "!USER_LAUNCH!"=="N" (
        set "LAUNCH_FLAG=0"
    ) else (
        set "LAUNCH_FLAG=1"
    )
)

echo.
echo ------------------------------------------------------------------------------
echo [*] Desplegando componentes en: !TARGET_DIR!...
echo ------------------------------------------------------------------------------
echo.

set "PS_ARGS=-TargetDir "!TARGET_DIR!" -AutoStart "!AUTOSTART_FLAG!" -LaunchNow "!LAUNCH_FLAG!""

if exist "%~dp0instalador_farmasys\Instalador_Script.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0instalador_farmasys\Instalador_Script.ps1" !PS_ARGS!
) else if exist "%~dp0Instalador_Script.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Instalador_Script.ps1" !PS_ARGS!
) else (
    echo [!] Error: No se encontro Instalador_Script.ps1
    pause
    exit /b 1
)

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [✓] FarmaSys POS instalado / actualizado exitosamente.
) else (
    echo.
    echo [!] Hubo una advertencia durante la instalacion (Codigo: %ERRORLEVEL%).
)

if "!UNATTENDED!"=="0" (
    echo.
    echo Presione cualquier tecla para cerrar el asistente...
    pause >nul
)
