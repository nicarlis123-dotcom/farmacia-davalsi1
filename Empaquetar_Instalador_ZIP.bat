@echo off
setlocal
title FarmaSys POS — Empaquetador de Distribucion (ZIP)
cd /d "%~dp0"
color 0A
cls

echo ==============================================================================
echo             FARMASYS POS -- GENERADOR DEL PAQUETE DISTRIBUIBLE ZIP             
echo ==============================================================================
echo.
echo Comprimiendo el instalador y binarios en 'FarmaSys_POS_Instalador_Completo.zip'...
echo Este archivo contiene todo lo necesario para instalar el sistema en cualquier PC.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$zipName = 'FarmaSys_POS_Instalador_Completo.zip'; " ^
  "if (Test-Path $zipName) { Remove-Item $zipName -Force }; " ^
  "$itemsToZip = @('Instalar_FarmaSys_POS.bat', 'MANUAL_DE_INSTALACION_Y_USO.md', 'farmasys.ico', 'FarmaSys_POS.py', 'backend', 'frontend', 'data', 'dist', 'instalador_farmasys'); " ^
  "$validItems = $itemsToZip | Where-Object { Test-Path $_ }; " ^
  "Compress-Archive -Path $validItems -DestinationPath $zipName -CompressionLevel Optimal; " ^
  "Write-Host '   [+] Paquete ZIP creado exitosamente:' $zipName -ForegroundColor Green; " ^
  "$sizeMB = [math]::Round((Get-Item $zipName).Length / 1MB, 2); " ^
  "Write-Host ('   [+] Tamano total: ' + $sizeMB + ' MB') -ForegroundColor Cyan"

echo.
echo ==============================================================================
echo El paquete ZIP esta listo para ser copiado a una memoria USB o compartido.
echo ==============================================================================
pause
