# GUÍA DEFINITIVA: CÓMO CREAR EL SERVIDOR 24/7 PARA FARMACIA DAVALSI
### (Sistema POS de Mostrador + App Móvil de Compras para Clientes)

Para que el sistema de cobro físico y la aplicación móvil de los clientes funcionen **24 horas al día, 7 días a la semana de forma ininterrumpida**, existen **dos caminos profesionales**. 

Elige el que mejor se adapte a tu comodidad y presupuesto:

---

## OPCIÓN 1: SERVIDOR EN LA NUBE (LA MÁS RECOMENDADA)
> **Ventaja principal:** Está encendido siempre en internet (99.9% disponibilidad). Si en la farmacia se apaga la computadora o se va la luz, los clientes desde sus casas **siguen comprando y haciendo pedidos sin interrupción**.

El backend de FarmaSys está construido con librerías nativas estándar de Python, por lo que **no necesita instalar librerías pesadas ni bases de datos complejas**.

### Pasos para desplegar en Render.com (Gratis o $7 USD/mes):

1. **Crear cuenta:**
   * Entra a [https://render.com](https://render.com) y regístrate con tu correo o cuenta de GitHub.
2. **Subir el proyecto a GitHub (o conectar repositorio):**
   * Sube los archivos de la carpeta `farmacia-davalsi` a un repositorio de GitHub (puedes ponerlo privado).
3. **Crear un nuevo Web Service en Render:**
   * Haz clic en **"New +"** → **"Web Service"**.
   * Selecciona tu repositorio de GitHub.
   * En **Environment**, elige `Python 3`.
   * En **Start Command**, escribe:
     ```bash
     python backend/server.py
     ```
   * En **Plan**, selecciona el plan Free (o Starter).
4. **¡Listo! Render te dará una URL web segura (HTTPS) permanente:**
   * Ejemplo: `https://farmacia-davalsi.onrender.com`
   * **Para los clientes (App Móvil / Web):** Entran desde su celular a `https://farmacia-davalsi.onrender.com/app`
   * **Para la Farmacia Física (POS Mostrador):** Abres en el navegador de la farmacia `https://farmacia-davalsi.onrender.com/sistema`

---

## OPCIÓN 2: COMPUTADORA FÍSICA DE LA FARMACIA COMO SERVIDOR PERMANENTE
> **Ventaja principal:** Costo $0 de hosting mensual. La base de datos vive físicamente en tu local comercial.

Si prefieres que la computadora que está en la farmacia sea el servidor central 24/7, debes asegurarle 3 cosas:

### 1. Inicio Automático en Windows (Ya incluido)
* Ejecuta en esa computadora el instalador:
  👉 **`Instalar_FarmaSys_POS.bat`**
* Cuando el instalador te pregunte:
  *`"¿Desea iniciar FarmaSys automáticamente al encender la PC? (S/N)"`*, presiona **S**.
* De esta forma, si la computadora se reinicia por una actualización de Windows, el servidor de la farmacia arranca automáticamente en segundo plano sin que nadie tenga que abrirlo manualmente.

### 2. Abrir el Servidor a los Celulares en la Calle (Cloudflare Tunnel Gratuito)
Para que los clientes con datos móviles (4G/5G) puedan comprar desde sus casas:
1. Descarga el ejecutable oficial y gratuito **`cloudflared.exe`** de Cloudflare:
   [https://github.com/cloudflare/cloudflared/releases/latest](https://github.com/cloudflare/cloudflared/releases/latest)
2. En la computadora de la farmacia, ejecuta:
   ```cmd
   cloudflared.exe tunnel --url http://localhost:8080
   ```
3. Cloudflare te dará una dirección pública fija y protegida contra ciberataques (ejemplo: `https://farmacia-davalsi.trycloudflare.com`).
4. Esa dirección web se coloca en la App móvil y se mantiene enlazada 24/7 con la PC de la farmacia.

### 3. Respaldo Eléctrico (Recomendado para el local físico)
* Conecta la computadora del mostrador y el router de internet (Claro, Altice, etc.) a una pequeña **batería UPS (Sistema de Alimentación Ininterrumpida)**.
* Esto evita que el sistema se apague si hay fluctuaciones de voltaje o cortes de electricidad breves.

---

## COMPARATIVA RÁPIDA: ¿CUÁL ELEGIR?

| Característica | Opción 1: Nube (Render / VPS) | Opción 2: PC Local de la Farmacia |
| :--- | :--- | :--- |
| **Disponibilidad 24/7** | ⭐️⭐️⭐️⭐️⭐️ (100% garantizada) | Depende de que la PC siga encendida |
| **Resistencia a apagones de luz** | Total (funciona aunque no haya luz en el local) | Requiere batería UPS en el local |
| **Costo** | Gratis o $5-$7 USD/mes | $0 mensual |
| **Facilidad de acceso para clientes** | Directo con dominio web oficial | Mediante túnel o WhatsApp directo |
| **Seguridad de copias de respaldo** | Automático en la nube | Se respalda en disco duro local |

---

## RECOMENDACIÓN FINAL:
Para empezar inmediatamente sin gastar dinero:
1. **Paso 1:** Utiliza la **PC de la farmacia con `Instalar_FarmaSys_POS.bat`** para tener el cobro físico funcionando en el local.
2. **Paso 2:** Los clientes desde sus casas hacen sus pedidos y los envían directo al **WhatsApp de la farmacia** (que funciona 24/7 sin importar si la PC está encendida en ese momento).
3. **Paso 3:** Cuando el volumen de clientes aumente, despliega el archivo `Dockerfile` o `Procfile` en **Render.com** para tener tu servidor en la nube profesional con dirección web oficial.
