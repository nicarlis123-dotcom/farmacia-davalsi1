# MANUAL DE INSTALACIÓN Y GUÍA DE OPERACIÓN — FARMASYS POS

**FarmaSys POS** es un sistema integral de punto de venta, facturación, control de inventario por unidad mínima y gestión multi-sucursal farmacéutica para computadoras de escritorio, terminales táctiles (All-in-One), tablets y smartphones.

---

## 1. REQUISITOS DEL SISTEMA

| Componente | Requisito Mínimo | Recomendado para Mostrador |
| :--- | :--- | :--- |
| **Sistema Operativo** | Windows 10 (64 bits) | Windows 10 / 11 (64 bits) |
| **Memoria RAM** | 2 GB | 4 GB o superior |
| **Espacio en Disco** | 200 MB libres | Disco SSD |
| **Navegador Web** | Microsoft Edge o Google Chrome | Microsoft Edge (Modo App Nativa) |
| **Lector de Códigos** | Cualquier lector USB / Bluetooth | Lector láser 1D/2D omnidireccional |
| **Impresora de Tickets** | Genérica / Térmica 58mm u 80mm | Térmica ESC/POS USB o de Red |
| **Red / Conectividad** | Localhost (Offline total) | Red WiFi local para tablets y celulares |

---

## 2. INSTALACIÓN EN 1 SOLO CLIC

1. Abra la carpeta del sistema o conecte la memoria USB que contiene el instalador.
2. Haga clic derecho sobre **`Instalar_FarmaSys_POS.bat`** y seleccione **"Ejecutar como administrador"** (o simplemente haga doble clic; el instalador solicitará permisos automáticamente).
3. El asistente interactivo en pantalla le solicitará:
   * **Directorio de destino:** Presione `ENTER` para aceptar la ruta estándar recomendada: `C:\FarmaSys_POS`.
   * **Inicio automático con Windows:** Presione `S` para que el sistema esté listo cada vez que se encienda la computadora de la farmacia.
   * **Lanzamiento inmediato:** Presione `S` para abrir el mostrador de ventas al terminar.
4. El instalador realizará automáticamente:
   * Detección y detención segura de instancias previas para evitar bloqueos de archivos.
   * Despliegue de los ejecutables y motor de base de datos.
   * **Preservación total de ventas e inventarios existentes:** Si se trata de una actualización, jamás sobreescribe sus bases de datos activas.
   * Creación de un **respaldo preventivo automático** en `data/backups/pre_update_...`.
   * Configuración de la regla en el **Firewall de Windows** para permitir la conexión de dispositivos móviles en la red local (puerto `8080`).
   * Creación del **Acceso Directo con Icono Oficial en el Escritorio**: *"FarmaSys POS - Mostrador de Cobro"*.
   * Creación de la carpeta del programa en el **Menú Inicio**.

---

## 3. ACTUALIZACIÓN DE UNA INSTALACIÓN EXISTENTE

Para aplicar nuevas versiones o mejoras del sistema en una computadora donde FarmaSys POS ya está instalado:
1. Simplemente ejecute nuevamente **`Instalar_FarmaSys_POS.bat`**.
2. El instalador detectará automáticamente la versión previa en `C:\FarmaSys_POS`:
   * Detendrá el servicio en segundo plano de manera limpia para liberar los archivos.
   * Creará una copia de seguridad preventiva de sus bases de datos en `C:\FarmaSys_POS\data\backups\`.
   * Actualizará todos los ejecutables, módulos de cobro, impresión térmica, estadísticas comparativas y reportes.
   * Mantendrá intactas todas sus ventas históricas, clientes deudores, inventarios y cuentas de usuario.
   * Reiniciará el mostrador de cobro con las funciones actualizadas.

---

## 4. INICIO Y OPERACIÓN EN EL MOSTRADOR FÍSICO

### Acceso Rápido desde el Escritorio
Haga doble clic en el acceso directo **"FarmaSys POS - Mostrador de Cobro"**:
* El sistema iniciará el servidor de base de datos en segundo plano de manera **100% silenciosa** (sin molestas ventanas negras de consola).
* Abrirá la interfaz directamente en **Modo Aplicación de Escritorio** (sin barras de URL ni pestañas de navegador), maximizada y lista para vender.

### Inicio de Sesión Independiente por Sucursal
1. Seleccione su sucursal en el menú desplegable (ej. *Davalsi Principal*, *Sucursal Naco*, etc.).
2. Ingrese con las credenciales de la farmacia:
   * **Administrador:** Clave maestra (acceso total a configuración, inventario, auditoría y reportes).
   * **Vendedor / Cajero:** Usuario y clave asignada en el módulo de personal (ej. `carmen.pos` / `vendedor123`).
3. El sistema conecta directamente a la **base de datos física separada** de esa farmacia (`farmacia_[id].db`), garantizando aislamiento y velocidad total.

---

## 5. FUNCIONALIDADES CLAVE DEL MOSTRADOR POS

### A. Escaneo y Venta por Unidad Mínima
* Apunte su lector de códigos de barras al medicamento o escriba su nombre/código en la barra superior.
* Seleccione la presentación vendida:
  * **Caja** (Aplica descuento por volumen de caja).
  * **Blíster** (Aplica descuento por blíster).
  * **Unidad / Tableta** (Precio base unitario exacto).
* El motor matemático calcula automáticamente el subtotal en RD$ y descuenta el stock en unidades mínimas reales en anaquel.

### B. Múltiples Formas de Pago y Cálculo de Cambio
* **Efectivo (RD$):** Ingrese el monto entregado por el cliente o use los botones de billetes rápidos (`+RD$100`, `+RD$200`, `+RD$500`, `+RD$1,000`, `+RD$2,000` o `Monto Exacto`). El sistema muestra en pantalla grande el **Vuelto / Cambio a Devolver**.
* **Tarjeta de Crédito/Débito:** Campo para número de comprobante o autorización POS del verifone.
* **Depósito / Transferencia:** Registro del número de transferencia bancaria.
* **Crédito / Fiado (Deudor):** Registra la cuenta por cobrar directamente en el módulo de deudores de esa sucursal.

### C. Cintillo de Estadísticas Comparativas de Venta
En la parte superior del mostrador POS verá siempre en vivo:
* **Venta Diaria:** Venta de Hoy vs. Venta de Ayer (RD$, facturas emitidas, diferencia neta y porcentaje ±%).
* **Venta Semanal:** Esta Semana (Lunes a Domingo) vs. Semana Anterior.
* **Venta Mensual:** Este Mes vs. Mes Anterior.
* Al completar cada venta en mostrador, las métricas y gráficos se actualizan de inmediato en tiempo real.

### D. Impresión Térmica y Reportes Oficiales
* **Recibo Térmico (80mm/58mm):** Facturas con desglose por ítem, subtotal, ITBIS, descuentos, efectivo entregado y cambio en RD$.
* **Reporte de Catálogo e Inventario Valorizado:** Imprime el stock completo desglosado en cajas, blísteres y unidades sueltas con valorización total en RD$.
* **Reporte de Reposición Urgente:** Alerta de medicamentos por debajo del stock mínimo con cálculo de déficit de reposición.
* **Control de Vencimientos FEFO:** Alerta de medicamentos con vencimiento menor o igual a 7 meses y productos vencidos.
* **Reportes de Venta Diaria, Mensual y Comparativa:** Balances interactivos imprimibles.
* **Cuentas por Cobrar y Auditoría:** Listado de deudores con abonos y registro de trazabilidad de operaciones.

### E. Cobranza Automatizada por WhatsApp
* Vaya a la pestaña **Deudores**.
* Haga clic en el botón verde **"💬 Cobrar por WhatsApp"** al lado de cualquier cliente con saldo pendiente.
* Se abrirá automáticamente WhatsApp (WhatsApp Web en PC o la app en móviles) con un mensaje formal personalizado detallando: saldo adeudado, detalle de medicamentos y cuentas bancarias de la farmacia para transferencia.

---

## 6. CONEXIÓN MULTI-DISPOSITIVO (TABLETS Y SMARTPHONES)

Cualquier dispositivo conectado a la misma red WiFi del local puede acceder al sistema sin instalar nada adicional:

1. El instalador muestra la dirección IP local de la computadora principal (ejemplo: `192.168.1.50`).
2. Desde la tablet o celular del supervisor o cajero, abra el navegador y escriba:
   ```
   http://192.168.1.50:8080/sistema
   ```
3. Podrá supervisar ventas, ingresar lotes en almacén o facturar pedidos móviles desde cualquier rincón del local.

---

## 7. HERRAMIENTAS DE MANTENIMIENTO Y SEGURIDAD

Dentro de la carpeta de instalación (`C:\FarmaSys_POS`):

* **`Iniciar_FarmaSys_POS.vbs`:** Lanzador silencioso de mostrador (usado por el acceso directo del escritorio).
* **`Iniciar_FarmaSys_Consola.bat`:** Abre el sistema mostrando la consola con registros en vivo de peticiones HTTP, ideal para diagnóstico técnico.
* **`Detener_FarmaSys_POS.bat`:** Cierra limpiamente todos los procesos del servidor.
* **`Desinstalar_FarmaSys_POS.bat`:** Desinstala el programa eliminando accesos directos y servicios, pero **crea una copia de respaldo automática e inviolable de todas las bases de datos en `C:\FarmaSys_POS_Backups\`** para que nunca se pierda el historial financiero.

---


---

## 8. RECEPCION Y DESPACHO DE PEDIDOS DE WHATSAPP AL SISTEMA POS

Para que los pedidos que los clientes envian desde la App por WhatsApp se vean directamente en la computadora de la farmacia para su aprobacion y despacho:

1. **Abrir WhatsApp Web en la computadora de la farmacia:**
   Abra en el navegador `https://web.whatsapp.com` con el numero de la farmacia (`809-555-0199`).
2. **Copiar el mensaje de pedido recibido:**
   Cuando un cliente confirme su compra, recibira un mensaje estructurado con el codigo `#DAV-XXXXX`, medicamentos, cantidades (Caja/Blister/Unidad), direccion de entrega, metodo de pago y cambio en efectivo.
3. **Ingresar al Sistema POS en 1 clic:**
   En la pantalla de cobro del POS (columna derecha, pestana *"📥 Pedidos App / Recetas"* o en la pestana *"Solicitudes desde la App"*), presione el boton verde:
   👉 **`📥 Pegar WhatsApp`**
4. **Validacion y Despacho:**
   El sistema leera el mensaje de inmediato, hara sonar la campana de nuevo pedido y colocara la tarjeta en la bandeja de despacho con los botones:
   - **`🔍 Ver Receta Medica`** (si el medicamento es regulado).
   - **`✓ Aprobar Despacho`**: Valida la orden, descuenta el inventario de las estanterias fisicas de la farmacia y genera el ticket termico para el repartidor o cliente.

---
## 9. SOPORTE Y CONTACTO TÉCNICO

* **Plataforma:** FarmaSys POS v2.5.0 Multi-Tenant
* **Moneda Oficial:** Pesos Dominicanos (RD$)
* **Soporte de Impresión:** Diálogo estándar `@media print` compatible con impresoras térmicas de 58mm / 80mm y formatos PDF de auditoría fiscal.
