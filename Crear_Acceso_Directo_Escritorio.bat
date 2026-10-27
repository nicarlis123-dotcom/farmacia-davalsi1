@echo off
title FarmaSys - Creador de Acceso Directo de Escritorio
color 0B
cls
echo ==============================================================================
echo           FARMASYS - CREADOR DE ACCESO DIRECTO EN EL ESCRITORIO
echo ==============================================================================
echo.
echo Este asistente creara un icono en el Escritorio con el logo oficial de FarmaSys.
echo Al hacerle doble clic, abrira directamente el Sistema POS de cobro como una
echo aplicacion independiente de Windows, sin barra de direcciones ni distracciones.
echo.

set /p URL_RENDER="Ingresa tu enlace de Render (ejemplo: https://farmacia-davalsi1.onrender.com): "

if "%URL_RENDER%"=="" (
    set "URL_RENDER=http://localhost:8080"
)

if "%URL_RENDER:~-1%"=="/" set "URL_RENDER=%URL_RENDER:~0,-1%"
set "TARGET_URL=%URL_RENDER%/sistema"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws = New-Object -ComObject WScript.Shell; $desktop = [System.Environment]::GetFolderPath('Desktop'); $shortcut = $ws.CreateShortcut((Join-Path $desktop 'FarmaSys - Caja POS.lnk')); $browser = if (Test-Path 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe') { 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' } else { 'msedge.exe' }; $shortcut.TargetPath = $browser; $shortcut.Arguments = '--app=%TARGET_URL%'; $shortcut.Description = 'FarmaSys - Sistema POS y Control de Farmacia'; $ico = Join-Path '%~dp0' 'farmasys.ico'; if (Test-Path $ico) { $shortcut.IconLocation = $ico }; $shortcut.Save(); Write-Host '   [OK] Acceso directo FarmaSys creado exitosamente en el Escritorio.' -ForegroundColor Green"

echo.
echo ==============================================================================
echo [LISTO] Ya tienes el icono 'FarmaSys - Caja POS' en tu Escritorio.
echo El adulto mayor o cajero solo debe hacerle doble clic para empezar a cobrar.
echo ==============================================================================
pause
