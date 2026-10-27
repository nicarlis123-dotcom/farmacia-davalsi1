# ==============================================================================
# FARMASYS POS v2.5.0 -- MOTOR DE INSTALACION Y ACTUALIZACION POWERSHELL
# Sistema Oficial de Cobro, Facturacion, Control de Inventario y Multi-Farmacia
# ==============================================================================
param (
    [string]$TargetDir = "C:\FarmaSys_POS",
    [string]$AutoStart = "0",
    [string]$LaunchNow = "1"
)

$ErrorActionPreference = "Stop"

$isAutoStart = ($AutoStart -eq "1" -or $AutoStart -eq "true" -or $AutoStart -eq "$true" -or $AutoStart -eq "s" -or $AutoStart -eq "S")
$isLaunchNow = ($LaunchNow -eq "1" -or $LaunchNow -eq "true" -or $LaunchNow -eq "$true" -or $LaunchNow -eq "s" -or $LaunchNow -eq "S")

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor DarkCyan
Write-Host "               FARMASYS POS v2.5.0 -- INSTALADOR OFICIAL                      " -ForegroundColor Cyan
Write-Host "         Sistema de Cobro de Mostrador, Facturacion e Inventarios             " -ForegroundColor White
Write-Host "                     Arquitectura Multi-Sucursal                              " -ForegroundColor DarkGray
Write-Host "==============================================================================" -ForegroundColor DarkCyan
Write-Host ""

# Directorios de origen
$CurrentScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ParentDir = Split-Path -Parent $CurrentScriptDir

function Resolve-SourcePath($relativePath) {
    $searchCandidates = @(
        (Join-Path $CurrentScriptDir $relativePath),
        (Join-Path $ParentDir $relativePath),
        (Join-Path (Split-Path -Parent $ParentDir) $relativePath)
    )
    foreach ($cand in $searchCandidates) {
        if (Test-Path -LiteralPath $cand) {
            return $cand
        }
    }
    return $null
}

Write-Host " [*] Directorio del Instalador: $CurrentScriptDir" -ForegroundColor Gray
Write-Host " [*] Directorio de Destino:    $TargetDir" -ForegroundColor Yellow
Write-Host ""

# ------------------------------------------------------------------------------
# 0. DETECCION Y DETENCION DE PROCESOS ACTIVOS (Para permitir actualizacion limpia)
# ------------------------------------------------------------------------------
Write-Host " [*] Comprobando procesos activos de FarmaSys POS..." -ForegroundColor Cyan

# Detener ejecutable compilado FarmaSys_POS si esta en ejecucion
$runningPos = Get-Process -Name "FarmaSys_POS" -ErrorAction SilentlyContinue
if ($runningPos) {
    Write-Host "   [!] Se detecto FarmaSys_POS.exe en ejecucion. Deteniendo para actualizar binarios..." -ForegroundColor Yellow
    $runningPos | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 900
}

# Detener cualquier proceso ejecutandose desde el directorio TargetDir
$currentPid = $PID
try {
    $targetProcs = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessId -ne $currentPid -and (
            ($_.ExecutablePath -and $_.ExecutablePath -like "$TargetDir\*") -or
            ($_.Name -eq "FarmaSys_POS.exe")
        )
    }
    foreach ($tp in $targetProcs) {
        Write-Host "   [!] Liberando bloqueo de archivo (Proceso $($tp.Name) PID $($tp.ProcessId))..." -ForegroundColor Yellow
        Stop-Process -Id $tp.ProcessId -Force -ErrorAction SilentlyContinue
    }
    if ($targetProcs) {
        Start-Sleep -Milliseconds 800
    }
} catch {
    # Ignorar errores de permisos en CIM
}

# Funcion auxiliar de copia con reintentos para evitar bloqueos transitorios
function Safe-CopyItem($src, $dst, [switch]$Recurse) {
    $attempts = 0
    $maxAttempts = 5
    while ($attempts -lt $maxAttempts) {
        try {
            $attempts++
            if ($Recurse) {
                Copy-Item -Path $src -Destination $dst -Recurse -Force -ErrorAction Stop
            } else {
                Copy-Item -Path $src -Destination $dst -Force -ErrorAction Stop
            }
            return
        } catch {
            if ($attempts -ge $maxAttempts) {
                Write-Host "   [!] Error critico copiando de $src a $dst : $($_.Exception.Message)" -ForegroundColor Red
                throw $_
            }
            Start-Sleep -Milliseconds 600
        }
    }
}

# ------------------------------------------------------------------------------
# 1. CREACION O VERIFICACION DEL DIRECTORIO DE DESTINO Y RESPALDO PRE-UPDATE
# ------------------------------------------------------------------------------
try {
    if (-not (Test-Path -LiteralPath $TargetDir)) {
        Write-Host " [1/6] Creando carpeta principal de instalacion..." -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    } else {
        Write-Host " [1/6] Instalacion previa detectada. Modo actualizacion activado." -ForegroundColor Green
        
        # Respaldo preventivo de bases de datos antes de actualizar
        $existingMaster = Join-Path $TargetDir "data\farmasys_master.db"
        if (Test-Path -LiteralPath $existingMaster) {
            $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupPath = Join-Path $TargetDir "data\backups\pre_update_$stamp"
            Write-Host "   [+] Creando respaldo contable preventivo en: data\backups\pre_update_$stamp..." -ForegroundColor Gray
            New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
            Copy-Item -Path "$TargetDir\data\*.db" -Destination $backupPath -Force -ErrorAction SilentlyContinue
            if (Test-Path "$TargetDir\data\tenants") {
                $backupTenants = Join-Path $backupPath "tenants"
                New-Item -ItemType Directory -Path $backupTenants -Force | Out-Null
                Copy-Item -Path "$TargetDir\data\tenants\*.db" -Destination $backupTenants -Force -ErrorAction SilentlyContinue
            }
            Write-Host "   [OK] Respaldo de seguridad completado." -ForegroundColor Green
        }
    }
} catch {
    Write-Host " [!] Error al preparar directorio de destino: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------------------
# 2. DESPLIEGUE DE EJECUTABLES, BACKEND, FRONTEND Y UTILITARIOS ACTUALIZADOS
# ------------------------------------------------------------------------------
Write-Host " [2/6] Desplegando componentes actualizados de FarmaSys POS..." -ForegroundColor Cyan

# Copiar binarios compilados (FarmaSys_POS.exe y _internal)
$DistSrc = Resolve-SourcePath "dist\FarmaSys_POS"
if (-not $DistSrc) {
    $DistSrc = Resolve-SourcePath "FarmaSys_POS.exe"
    if ($DistSrc) { $DistSrc = Split-Path -Parent $DistSrc }
}

if ($DistSrc -and (Test-Path -LiteralPath $DistSrc)) {
    Write-Host "   [+] Desplegando binario ejecutable y dependencias nativas..." -ForegroundColor Gray
    Safe-CopyItem -src "$DistSrc\*" -dst $TargetDir -Recurse
    Write-Host "   [OK] FarmaSys_POS.exe actualizado correctamente." -ForegroundColor Green
} else {
    Write-Host "   [i] Nota: Binario compilado no encontrado en origen; se utilizara lanzador Python." -ForegroundColor Yellow
}

# Desplegar backend (Motor de ventas, base de datos y reportes)
$BackendSrc = Resolve-SourcePath "backend"
if ($BackendSrc) {
    $BackendDst = Join-Path $TargetDir "backend"
    New-Item -ItemType Directory -Path $BackendDst -Force | Out-Null
    Safe-CopyItem -src "$BackendSrc\*" -dst $BackendDst -Recurse
    Write-Host "   [OK] Modulo de logica de cobro, reportes y base de datos actualizado." -ForegroundColor Green
}

# Desplegar frontend (POS, Estadisticas comparativas, Impresion termica, Modales)
$FrontendSrc = Resolve-SourcePath "frontend"
if ($FrontendSrc) {
    $FrontendDst = Join-Path $TargetDir "frontend"
    New-Item -ItemType Directory -Path $FrontendDst -Force | Out-Null
    Safe-CopyItem -src "$FrontendSrc\*" -dst $FrontendDst -Recurse
    Write-Host "   [OK] Modulo de interfaz de mostrador, reportes e impresion actualizado." -ForegroundColor Green
}

# Desplegar uploads
New-Item -ItemType Directory -Path "$TargetDir\uploads\recetas" -Force | Out-Null

# Copiar scripts auxiliares y herramientas de administracion
$AuxList = @(
    "FarmaSys_POS.py",
    "farmasys.ico",
    "MANUAL_DE_INSTALACION_Y_USO.md",
    "Iniciar_FarmaSys_POS.vbs",
    "Iniciar_FarmaSys_Consola.bat",
    "Detener_FarmaSys_POS.bat",
    "Desinstalar_FarmaSys_POS.bat"
)
foreach ($aux in $AuxList) {
    $found = Resolve-SourcePath $aux
    if (-not $found) {
        $found = Resolve-SourcePath "instalador_farmasys\$aux"
    }
    if ($found) {
        $leafName = Split-Path -Leaf $aux
        Safe-CopyItem -src $found -dst (Join-Path $TargetDir $leafName)
    }
}
Write-Host "   [OK] Scripts auxiliares y herramientas de mostrador configurados." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 3. GESTION DE BASES DE DATOS MULTI-SUCURSAL (PRESERVACION ESTRICTA DE VENTAS)
# ------------------------------------------------------------------------------
Write-Host " [3/6] Configurando almacenamiento de bases de datos independientes..." -ForegroundColor Cyan
$TargetDataDir = Join-Path $TargetDir "data"
$TargetTenantsDir = Join-Path $TargetDataDir "tenants"
$TargetBackupsDir = Join-Path $TargetDataDir "backups"
New-Item -ItemType Directory -Path $TargetTenantsDir -Force | Out-Null
New-Item -ItemType Directory -Path $TargetBackupsDir -Force | Out-Null

$DataSrc = Resolve-SourcePath "data"
if ($DataSrc) {
    $MasterSrc = Join-Path $DataSrc "farmasys_master.db"
    $MasterDst = Join-Path $TargetDataDir "farmasys_master.db"
    if ((-not (Test-Path -LiteralPath $MasterDst)) -and (Test-Path -LiteralPath $MasterSrc)) {
        Copy-Item -Path $MasterSrc -Destination $MasterDst -Force
        Write-Host "   [+] Base de datos maestra inicializada." -ForegroundColor Gray
    } else {
        Write-Host "   [OK] Base de datos maestra existente preservada (Sin sobrescritura)." -ForegroundColor Green
    }

    $TenantsSrcDir = Join-Path $DataSrc "tenants"
    if (Test-Path -LiteralPath $TenantsSrcDir) {
        Get-ChildItem -Path "$TenantsSrcDir\*.db" -ErrorAction SilentlyContinue | ForEach-Object {
            $tenantDst = Join-Path $TargetTenantsDir $_.Name
            if (-not (Test-Path -LiteralPath $tenantDst)) {
                Copy-Item -Path $_.FullName -Destination $tenantDst -Force
                Write-Host "   [+] Base de datos de sucursal inicializada: $($_.Name)" -ForegroundColor Gray
            } else {
                Write-Host "   [OK] Base de datos de sucursal preservada con sus ventas: $($_.Name)" -ForegroundColor Green
            }
        }
    }
}

# ------------------------------------------------------------------------------
# 4. CREACION Y ACTUALIZACION DE ACCESOS DIRECTOS CON ICONO OFICIAL
# ------------------------------------------------------------------------------
Write-Host " [4/6] Creando accesos directos oficiales en Escritorio y Menu Inicio..." -ForegroundColor Cyan
$WshShell = New-Object -ComObject WScript.Shell
$Desktop = [System.Environment]::GetFolderPath('Desktop')
$IcoPath = Join-Path $TargetDir "farmasys.ico"
$VbsPath = Join-Path $TargetDir "Iniciar_FarmaSys_POS.vbs"
$BatConsolePath = Join-Path $TargetDir "Iniciar_FarmaSys_Consola.bat"
$BatStopPath = Join-Path $TargetDir "Detener_FarmaSys_POS.bat"
$BatUninstallPath = Join-Path $TargetDir "Desinstalar_FarmaSys_POS.bat"
$ManualPath = Join-Path $TargetDir "MANUAL_DE_INSTALACION_Y_USO.md"
$WscriptExe = Join-Path ([System.Environment]::GetFolderPath('System')) "wscript.exe"

$vbsQuoteArg = '"' + $VbsPath + '"'

# Acceso Directo de Escritorio: Mostrador de Cobro
$LnkDesktopPath = Join-Path $Desktop "FarmaSys POS - Mostrador de Cobro.lnk"
$LnkDesktop = $WshShell.CreateShortcut($LnkDesktopPath)
if (Test-Path -LiteralPath $VbsPath) {
    $LnkDesktop.TargetPath = $WscriptExe
    $LnkDesktop.Arguments = $vbsQuoteArg
} elseif (Test-Path -LiteralPath "$TargetDir\FarmaSys_POS.exe") {
    $LnkDesktop.TargetPath = "$TargetDir\FarmaSys_POS.exe"
} else {
    $LnkDesktop.TargetPath = $BatConsolePath
}
$LnkDesktop.WorkingDirectory = $TargetDir
if (Test-Path -LiteralPath $IcoPath) {
    $LnkDesktop.IconLocation = "$IcoPath,0"
}
$LnkDesktop.Description = "FarmaSys POS - Sistema de Cobro e Inventario Farmaceutico"
$LnkDesktop.Save()
Write-Host "   [OK] Acceso de escritorio configurado: 'FarmaSys POS - Mostrador de Cobro'." -ForegroundColor Green

# Accesos en Menu de Programas de Windows
$ProgramsDir = [System.Environment]::GetFolderPath('Programs')
$StartMenuDir = Join-Path $ProgramsDir "FarmaSys POS"
New-Item -ItemType Directory -Path $StartMenuDir -Force | Out-Null

# 1. Mostrador de Ventas (Modo silencioso)
$LnkStart1 = $WshShell.CreateShortcut((Join-Path $StartMenuDir "FarmaSys POS (Mostrador de Ventas).lnk"))
$LnkStart1.TargetPath = $WscriptExe
$LnkStart1.Arguments = $vbsQuoteArg
$LnkStart1.WorkingDirectory = $TargetDir
if (Test-Path -LiteralPath $IcoPath) { $LnkStart1.IconLocation = "$IcoPath,0" }
$LnkStart1.Description = "Iniciar FarmaSys POS (Modo Silencioso)"
$LnkStart1.Save()

# 2. Modo Consola con Logs
$LnkStart2 = $WshShell.CreateShortcut((Join-Path $StartMenuDir "FarmaSys POS (Modo Consola con Logs).lnk"))
$LnkStart2.TargetPath = $BatConsolePath
$LnkStart2.WorkingDirectory = $TargetDir
if (Test-Path -LiteralPath $IcoPath) { $LnkStart2.IconLocation = "$IcoPath,0" }
$LnkStart2.Description = "Iniciar FarmaSys POS viendo logs de transacciones en consola"
$LnkStart2.Save()

# 3. Detener Servicio
$LnkStart3 = $WshShell.CreateShortcut((Join-Path $StartMenuDir "Detener Servicio FarmaSys.lnk"))
$LnkStart3.TargetPath = $BatStopPath
$LnkStart3.WorkingDirectory = $TargetDir
$LnkStart3.Description = "Detener servidor local de FarmaSys POS"
$LnkStart3.Save()

# 4. Manual de Instalacion y Uso
$LnkStart4 = $WshShell.CreateShortcut((Join-Path $StartMenuDir "Manual de Instalacion y Uso.lnk"))
$LnkStart4.TargetPath = $ManualPath
$LnkStart4.WorkingDirectory = $TargetDir
$LnkStart4.Save()

# 5. Desinstalar FarmaSys POS
$LnkStart5 = $WshShell.CreateShortcut((Join-Path $StartMenuDir "Desinstalar FarmaSys POS.lnk"))
$LnkStart5.TargetPath = $BatUninstallPath
$LnkStart5.WorkingDirectory = $TargetDir
$LnkStart5.Save()

Write-Host "   [OK] Menu Inicio configurado con herramientas de mostrador y administracion." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 5. CONFIGURACION DE RED Y FIREWALL DE WINDOWS (PUERTO 8080)
# ------------------------------------------------------------------------------
Write-Host " [5/6] Habilitando puerto 8080 en el Firewall para terminales WiFi..." -ForegroundColor Cyan
try {
    netsh advfirewall firewall delete rule name="FarmaSys POS (Puerto 8080)" *> $null
    netsh advfirewall firewall add rule name="FarmaSys POS (Puerto 8080)" dir=in action=allow protocol=TCP localport=8080 *> $null
    Write-Host "   [OK] Regla de Firewall TCP 8080 configurada exitosamente." -ForegroundColor Green
} catch {
    Write-Host "   [!] Nota: No se pudo configurar el firewall automaticamente." -ForegroundColor Yellow
}

# Inicio automatico con Windows
$StartupDir = [System.Environment]::GetFolderPath('Startup')
$StartupLnkPath = Join-Path $StartupDir "FarmaSys POS.lnk"
if ($isAutoStart) {
    $LnkStartup = $WshShell.CreateShortcut($StartupLnkPath)
    $LnkStartup.TargetPath = $WscriptExe
    $LnkStartup.Arguments = $vbsQuoteArg
    $LnkStartup.WorkingDirectory = $TargetDir
    if (Test-Path -LiteralPath $IcoPath) { $LnkStartup.IconLocation = "$IcoPath,0" }
    $LnkStartup.Save()
    Write-Host "   [OK] Inicio automatico con Windows habilitado." -ForegroundColor Green
} else {
    if (Test-Path -LiteralPath $StartupLnkPath) {
        Remove-Item -Path $StartupLnkPath -Force -ErrorAction SilentlyContinue
    }
}

# ------------------------------------------------------------------------------
# 6. FINALIZACION Y DATOS DE CONEXION
# ------------------------------------------------------------------------------
Write-Host " [6/6] Finalizando instalacion..." -ForegroundColor Cyan
$LocalIP = "127.0.0.1"
try {
    $netIP = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254*" } | Select-Object -First 1)
    if ($netIP) {
        $LocalIP = $netIP.IPAddress
    }
} catch {
    $LocalIP = "127.0.0.1"
}

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor DarkCyan
Write-Host "                 INSTALACION COMPLETADA CON EXITO                             " -ForegroundColor Green
Write-Host "==============================================================================" -ForegroundColor DarkCyan
Write-Host " [*] Ubicacion de FarmaSys POS: $TargetDir" -ForegroundColor White
Write-Host " [*] Acceso Local (Esta PC):    http://localhost:8080/sistema" -ForegroundColor Cyan
Write-Host " [*] Acceso Movil / Red WiFi:   http://$($LocalIP):8080/sistema" -ForegroundColor Cyan
Write-Host " [*] App de Clientes/Pacientes: http://localhost:8080/app" -ForegroundColor Cyan
Write-Host " [*] Acceso Directo:            Creado en el Escritorio" -ForegroundColor White
Write-Host "==============================================================================" -ForegroundColor DarkCyan
Write-Host ""

if ($isLaunchNow) {
    Write-Host " [*] Abriendo FarmaSys POS..." -ForegroundColor Green
    if (Test-Path -LiteralPath $VbsPath) {
        Start-Process -FilePath $WscriptExe -ArgumentList $vbsQuoteArg -WorkingDirectory $TargetDir
    } elseif (Test-Path -LiteralPath (Join-Path $TargetDir "FarmaSys_POS.exe")) {
        Start-Process -FilePath (Join-Path $TargetDir "FarmaSys_POS.exe") -WorkingDirectory $TargetDir
    } else {
        Start-Process -FilePath $BatConsolePath -WorkingDirectory $TargetDir
    }
}
