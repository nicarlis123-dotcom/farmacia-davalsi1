@echo off
title Farmacia Davalsi — App de Pacientes (/app) + Sistema de Farmacias (/sistema)
echo ====================================================================
echo   INICIANDO ARQUITECTURA SEPARADA MULTI-FARMACIA (RD$)
echo   1) App de Pacientes:        http://localhost:8080/app
echo   2) Sistema de Farmacias:    http://localhost:8080/sistema
echo ====================================================================
start "" "http://localhost:8080/app"
start "" "http://localhost:8080/sistema"
python "%~dp0backend\server.py"
pause
