"""
=============================================================================
  FARMASYS POS — SISTEMA INTEGRAL DE COBRO FARMACÉUTICO Y MULTI-SUCURSAL
  Lanzador Principal y Servidor de Mostrador Físico
=============================================================================
"""

import os
import sys

# Asegurar codificación UTF-8 segura para consolas Windows
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

import time
import socket
import urllib.request
import urllib.error
import subprocess
import webbrowser
from threading import Thread

# Configuración de rutas compatibles con ejecución normal y congelada (PyInstaller .exe)
if getattr(sys, 'frozen', False):
    APP_DIR = os.path.dirname(os.path.abspath(sys.executable))
    BUNDLE_DIR = getattr(sys, '_MEIPASS', APP_DIR)
else:
    APP_DIR = os.path.dirname(os.path.abspath(__file__))
    BUNDLE_DIR = APP_DIR

BACKEND_DIR = os.path.join(APP_DIR, "backend")
if not os.path.isdir(BACKEND_DIR) and os.path.isdir(os.path.join(BUNDLE_DIR, "backend")):
    BACKEND_DIR = os.path.join(BUNDLE_DIR, "backend")

sys.path.insert(0, BACKEND_DIR)
sys.path.insert(0, APP_DIR)

DEFAULT_PORT = 8080


def get_local_ip() -> str:
    """Detecta la dirección IP de la red local para conectar tablets o smartphones."""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"


def is_port_in_use(port: int) -> bool:
    """Comprueba si el puerto ya está en uso."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(0.5)
        return s.connect_ex(("127.0.0.1", port)) == 0


def is_farmasys_running(port: int) -> bool:
    """Verifica si FarmaSys ya está respondiendo en el puerto especificado."""
    try:
        url = f"http://127.0.0.1:{port}/api/health"
        req = urllib.request.Request(url, headers={"User-Agent": "FarmaSysLauncher"})
        with urllib.request.urlopen(req, timeout=1.5) as resp:
            return resp.status == 200
    except Exception:
        return False


def find_browser_app_mode(url: str) -> bool:
    """
    Intenta abrir Microsoft Edge o Google Chrome en MODO APLICACIÓN NATIVO (--app=...).
    Esto elimina la barra de navegación, pestañas y botones del navegador,
    ofreciendo una experiencia 100% de software de escritorio comercial POS.
    """
    edge_paths = [
        os.path.expandvars(r"%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"),
        os.path.expandvars(r"%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"),
        os.path.expandvars(r"%LocalAppData%\Microsoft\Edge\Application\msedge.exe"),
    ]
    chrome_paths = [
        os.path.expandvars(r"%ProgramFiles%\Google\Chrome\Application\chrome.exe"),
        os.path.expandvars(r"%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"),
        os.path.expandvars(r"%LocalAppData%\Google\Chrome\Application\chrome.exe"),
    ]

    for p in edge_paths + chrome_paths:
        if os.path.isfile(p):
            try:
                subprocess.Popen([p, f"--app={url}", "--start-maximized"])
                return True
            except Exception:
                pass

    return False


def launch_pos_window(port: int) -> None:
    """Abre la interfaz de cobro FarmaSys POS en el navegador o ventana de app."""
    url = f"http://localhost:{port}/sistema"
    time.sleep(1.2) # Breve pausa para asegurar que el servidor HTTP esté listo
    
    # Intentar modo aplicación nativo para terminales de mostrador
    opened = find_browser_app_mode(url)
    if not opened:
        webbrowser.open(url)


def main():
    port = int(os.environ.get("FARMASYS_PORT", DEFAULT_PORT))
    local_ip = get_local_ip()

    print("==============================================================================")
    print("                     FARMASYS POS — SISTEMA DE COBRO                          ")
    print("             Ecosistema Farmacéutico y Gestión Multi-Sucursal                 ")
    print("==============================================================================")
    print(f" [*] Directorio de Trabajo: {APP_DIR}")
    print(f" [*] Terminal Local POS:   http://localhost:{port}/sistema")
    print(f" [*] Red Local / WiFi:     http://{local_ip}:{port}/sistema")
    print(f" [*] App Pacientes:        http://localhost:{port}/app")
    print("==============================================================================")

    # Si FarmaSys ya está corriendo en segundo plano, abrir la ventana directamente
    if is_farmasys_running(port):
        print(" [i] El servicio FarmaSys ya está activo en segundo plano.")
        print(" [i] Abriendo mostrador de venta...")
        launch_pos_window(port)
        return

    # Verificar si el puerto está ocupado por otra aplicación
    if is_port_in_use(port) and not is_farmasys_running(port):
        print(f" [!] Advertencia: El puerto {port} está ocupado por otro proceso.")
        print(f" [!] Intentando conectar con el servicio...")

    # Iniciar hilo para abrir la ventana de venta
    ui_thread = Thread(target=launch_pos_window, args=(port,), daemon=True)
    ui_thread.start()

    # Importar y ejecutar el servidor web
    try:
        from server import run_server
        print(" [OK] Servidor FarmaSys iniciado con éxito.")
        print(" [i] Presione Ctrl+C en esta consola para detener el servidor.")
        run_server(port)
    except KeyboardInterrupt:
        print("\n [!] Servidor FarmaSys detenido correctamente.")
    except Exception as exc:
        print(f"\n [ERROR] No se pudo iniciar el servidor: {exc}")
        input("\nPresione Enter para salir...")


if __name__ == "__main__":
    main()
