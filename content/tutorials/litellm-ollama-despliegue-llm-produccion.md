---
title: "Despliega tus propios LLMs en Producción con Ollama y LiteLLM: Guía Paso a Paso"
date: 2026-07-12
description: "¿Quieres dejar de pagar APIs de OpenAI? Aprende a desplegar tus propios LLMs locales en producción con Ollama (GPU) y LiteLLM para gestionar API Keys, presupuestos y consumo."
slug: "litellm-ollama-despliegue-llm-produccion"
aliases:
  - "/tutorials/guía-de-producción-despliegue-de-llms-con-ollama-y-gobernanza-de-acceso-con-litellm/"
tags: ["ollama", "litellm", "llm", "inteligencia-artificial", "docker", "gpu", "tutorial"]
icon: "🤖"
cover: "/images/litellm-ollama/00-portada.png"
author: "Brayan Herrera"
youtube: "https://youtube.com/@BramenDev"
---

Los modelos de lenguaje de código abierto (Open Source) se han convertido en una alternativa sumamente potente y viable frente a las APIs comerciales. Nos permiten evitar las limitaciones de cuotas, reducir costos de tokens a gran escala y, lo más importante, garantizar la privacidad total de nuestros datos.

En este tutorial paso a paso, aprenderás a desplegar una infraestructura de nivel de producción desde cero. Utilizaremos **[Ollama](https://ollama.com)** para ejecutar modelos de lenguaje locales acelerados por GPU en un servidor privado virtual (VPS), y **[LiteLLM](https://litellm.ai)** como un proxy inverso compatible con la API de OpenAI para gestionar la gobernanza, crear API keys personalizadas, auditar el consumo y establecer presupuestos por usuario o equipo de trabajo.

---

## 🗺️ ¿Qué veremos en este tutorial?

- [Paso 1: Elección y aprovisionamiento del VPS (con GPU)](#paso-1-elección-y-aprovisionamiento-del-vps-con-gpu)
- [Paso 2: Conexión SSH y preparación del sistema](#paso-2-conexión-ssh-y-preparación-del-sistema)
- [Paso 3: Instalación de Docker y Docker Compose](#paso-3-instalación-de-docker-y-docker-compose)
- [Paso 4: Instalación del driver NVIDIA y NVIDIA Container Toolkit](#paso-4-instalación-del-driver-nvidia-y-nvidia-container-toolkit)
- [Paso 5: Configuración y despliegue de la infraestructura (Docker Compose)](#paso-5-configuración-y-despliegue-de-la-infraestructura-docker-compose)
- [Paso 6: Descarga y ejecución de modelos de alta capacidad (Gemma 4)](#paso-6-descarga-y-ejecución-de-modelos-de-alta-capacidad-gemma-4)
- [Paso 7: Gobernanza de acceso y gestión de API Keys con LiteLLM](#paso-7-gobernanza-de-acceso-y-gestión-de-api-keys-con-litellm)
- [Paso 8: Integración y pruebas de consumo de la API](#paso-8-integración-y-pruebas-de-consumo-de-la-api)

---

<div class="youtube-embed">
    <div class="youtube-embed-header">
        <i class="fab fa-youtube" style="color: #ff0000;"></i>
        <span>📺 Video tutorial en producción</span>
    </div>
    <div class="youtube-embed-coming-soon">
        <div class="youtube-coming-soon-icon">🎬</div>
        <p class="youtube-coming-soon-text">
            Estoy grabando el video paso a paso de este tutorial para que puedas verlo en acción.
        </p>
        <p class="youtube-coming-soon-subscribe">
            🔔 <strong>Suscríbete a <a href="https://youtube.com/@BramenDev" target="_blank" rel="noopener">@BramenDev</a></strong> y activa la campanita para que YouTube te avise en cuanto esté publicado. ¡No te lo pierdas! 🚀
        </p>
    </div>
</div>

<!--
<div class="youtube-embed">
    <div class="youtube-embed-header">
        <i class="fab fa-youtube" style="color: #ff0000;"></i>
        <span>Mira el video tutorial completo</span>
    </div>
    <div class="youtube-embed-wrapper">
        <iframe src="https://www.youtube.com/embed/VIDEO_ID" 
                title="Video tutorial: Despliegue de LLMs con Ollama y LiteLLM"
                frameborder="0" 
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                allowfullscreen>
        </iframe>
    </div>
    <p class="youtube-embed-caption">
        Suscríbete a <a href="https://youtube.com/@BramenDev" target="_blank" rel="noopener">@BramenDev</a> para más contenido 🚀
    </p>
</div>
-->
---

## Paso 1: Elección y aprovisionamiento del VPS (con GPU)

Lo primero es elegir un proveedor de nube que ofrezca instancias con GPU dedicadas. Para este tutorial, utilizaremos **Linode (Akamai)**, que ofrece una excelente relación calidad-precio para servidores con GPU.

> *Nota: También puedes seguir esta guía en cualquier servidor local o VPS que corra una distribución Linux basada en Debian/Ubuntu.*

Ingresamos a Linode y hacemos login https://login.linode.com/login (si no tienes cuenta puedes crear una):

![Login de Linode](/images/litellm-ollama/16-login-linode.png)

Nos dejará en una pestaña donde podremos encontrar el boton de crear linode:

![Botón de crear Linode](/images/litellm-ollama/17-boton-crear-linode.png)

Para este caso práctico, seleccionamos una instancia en la región **US, Seattle, WA (us-sea)** con una GPU dedicada:

![Selección de VPS con GPU](/images/litellm-ollama/01-seleccion-vps.png)

La VPS elegida cuenta con las siguientes especificaciones técnicas:

| Especificación | Detalle |
| :--- | :--- |
| **Arquitectura** | NVIDIA Ada Lovelace |
| **Memoria VRAM** | 20 GB GDDR6 con ECC |
| **Núcleos CUDA** | 6,144 |
| **Núcleos Tensor** | 192 (4ª Generación) |
| **Rendimiento FP32** | 19.2 TFLOPs |
| **RAM del Sistema** | 16 GB |
| **vCPUs** | 4 Cores |

### ⚡ ¿Qué significan estas especificaciones en la práctica?

Para entender el impacto real de este hardware en producción, debemos traducir estos números a rendimiento, velocidad de generación de texto (tokens por segundo) y concurrencia de usuarios:

1. **Memoria VRAM (20 GB GDDR6): El factor limitante del tamaño del modelo**
   - La VRAM determina qué tan grande puede ser el modelo que ejecutes. Un modelo cuantizado en formato de 4 bits (Q4) requiere aproximadamente **0.7 GB de VRAM por cada 1,000 millones de parámetros (1B)**, más unos 2-4 GB adicionales para el contexto (KV Cache).
   - Con **20 GB de VRAM**, puedes cargar completamente en GPU modelos de hasta **14B o 20B parámetros** (como *Gemma 4 12B* o *Qwen 2.5 14B*) con un rendimiento óptimo. Modelos más grandes (como *Gemma 4 31B*) requerirán "offloading" (repartir capas entre GPU y CPU/RAM del sistema), lo que reduce drásticamente la velocidad de generación.

2. **Núcleos CUDA (6,144) y Rendimiento FP32 (19.2 TFLOPs): Velocidad de procesamiento (Tokens/seg)**
   - Los núcleos CUDA realizan los cálculos matemáticos en paralelo necesarios para procesar los pesos del modelo.
   - En un modelo de **12B parámetros** cargado al 100% en esta GPU, puedes esperar una velocidad de generación de entre **35 y 50 tokens por segundo (t/s)** para un solo usuario. Esto es más rápido de lo que un humano promedio puede leer en tiempo real.

3. **Núcleos Tensor de 4ª Generación (192): Aceleración de Inteligencia Artificial**
   - Los núcleos Tensor están diseñados específicamente para operaciones de multiplicación de matrices de precisión mixta (FP16/INT8/INT4), que son el núcleo de los LLMs.
   - Al usar cuantizaciones (como Q4_K_M), estos núcleos aceleran drásticamente la inferencia y reducen el consumo de energía y temperatura de la tarjeta.

4. **Capacidad de Usuarios Concurrentes**
   - **Usuarios concurrentes reales:** Con esta GPU, puedes servir de forma fluida a unos **5 a 10 usuarios haciendo peticiones simultáneas** en tiempo real sobre un modelo de 12B sin que la latencia (Time to First Token) se vuelva molesta.
   - **Usuarios activos totales:** Gracias a que las peticiones web no ocurren exactamente al mismo milisegundo, esta infraestructura puede soportar fácilmente a un equipo de **50 a 100 usuarios activos** que utilicen la API de forma intermitente durante el día.

---

### Configuración de seguridad inicial

1. **Contraseña de Root:** Define una contraseña altamente segura. Puedes generar una contraseña aleatoria fuerte desde tu terminal local con:
   ```bash
   openssl rand -base64 32
   ```
   ![Configuración de contraseña](/images/litellm-ollama/02-config-contrasena.png)

2. **Firewall:** Asigna un Firewall por defecto. Se recomienda crear reglas personalizadas limitando los puertos de acceso solo a tus IPs de confianza.
   ![Asignación de Firewall](/images/litellm-ollama/03-asignacion-firewall.png)

3. **Creación del VPS:** Haz clic en "Create Linode" para iniciar el aprovisionamiento.
   ![Crear VPS](/images/litellm-ollama/04-crear-vps.png)

Una vez que comience el proceso de aprovisionamiento, la máquina se iniciará e instalará el sistema operativo (Ubuntu 22.04 LTS o similar):

![Aprovisionamiento en curso](/images/litellm-ollama/05-aprovisionamiento.png)

Al finalizar, copia la IP pública asignada a tu VPS (en este ejemplo: `IP_DE_TU_VPS`).

---

## Paso 2: Conexión SSH y preparación del sistema

Abre tu terminal local y conéctate al servidor mediante SSH usando el usuario `root` y la IP de tu VPS:

```bash
ssh root@IP_DE_TU_VPS
```

![Conexión SSH](/images/litellm-ollama/06-conexion-ssh.png)

Si es la primera vez que te conectas, confirma la autenticidad de la llave SSH escribiendo `yes` y presionando `Enter`:

![Confirmación de llave SSH](/images/litellm-ollama/07-confirmacion-ssh.png)

Luego, ingresa la contraseña segura que creaste previamente (no se mostrará en pantalla por motivos de seguridad):

![Ingreso de contraseña](/images/litellm-ollama/08-ingreso-contrasena.png)

### Monitoreo de recursos con htop

Una vez dentro del servidor, actualizaremos los repositorios e instalaremos htop para monitorear el uso de CPU y memoria RAM. Como estamos logueados como `root`, no es necesario anteponer `sudo`.

```bash
apt update && apt install -y htop
```

Ejecuta htop para verificar el estado inicial del sistema:

```bash
htop
```

![Monitoreo con htop](/images/litellm-ollama/09-monitoreo-htop.png)

Como se observa, disponemos de 4 núcleos de CPU y 15.6 GB de memoria RAM disponibles. Para salir de htop, presiona `F10` o `Ctrl + C`.

### Configuración del firewall con UFW

Proteger el servidor con un firewall es obligatorio antes de exponer cualquier servicio. Usaremos **UFW (Uncomplicated Firewall)** para permitir solo el tráfico necesario.

> **⚠️ Importante:** Solo **LiteLLM** (puerto `4000`) necesita estar expuesto para que los usuarios puedan consumir la API. **Ollama** y **PostgreSQL** se comunican internamente a través de la red de Docker, por lo que NO deben abrirse puertos para ellos.

```bash
# 1. Permitir SSH (para que puedas seguir conectándote)
ufw allow ssh

# 2. Permitir LiteLLM (solo desde IPs de confianza)
ufw allow from TU_IP_DE_CONFIANZA to any port 4000 proto tcp

# 3. Habilitar UFW
ufw --force enable
```

> ⚡ Si necesitas acceder desde varias IPs, puedes agregar múltiples reglas o usar una subred (ej. `ufw allow from 192.168.1.0/24 to any port 4000 proto tcp`).

Verifica que las reglas quedaron activas:

```bash
ufw status verbose
```

Deberías ver una salida similar a esta:

```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
4000/tcp                   ALLOW IN    TU_IP_DE_CONFIANZA
22/tcp (v6)                ALLOW IN    Anywhere (v6)
```

> **🔒 Nota:** El puerto **SSH (22)** queda abierto para que puedas seguir conectándote. **Ollama (11434)** y **PostgreSQL (5432)** no tienen ninguna regla de entrada porque solo se comunican entre sí a través de la red interna de Docker Compose, lo que los mantiene seguros y aislados del exterior. **LiteLLM (4000)** es el único punto de entrada a la infraestructura.

---

## Paso 3: Instalación de Docker y Docker Compose

Utilizaremos Docker para desplegar de manera limpia y aislada todos nuestros servicios (Ollama, PostgreSQL y LiteLLM).

1. Descarga el script oficial de instalación de Docker:
   ```bash
   curl -fsSL https://get.docker.com -o install-docker.sh
   ```

2. Verifica la descarga:
   ```bash
   ls -l install-docker.sh
   ```

3. Ejecuta el script de instalación:
   ```bash
   sh install-docker.sh
   ```

4. Verifica que Docker y Docker Compose se hayan instalado correctamente:
   ```bash
   docker --version
   ```
   ![Versión de Docker](/images/litellm-ollama/10-docker-version.png)

   ```bash
   docker compose version
   ```
   ![Versión de Docker Compose](/images/litellm-ollama/11-docker-compose-version.png)

---

## Paso 4: Instalación del driver NVIDIA y NVIDIA Container Toolkit

El driver NVIDIA es crítico para que Ollama pueda usar la GPU. **Para arquitecturas Ada Lovelace (como RTX 4000 Ada), necesitas driver 550 o más nuevo.**

> **⚠️ Importante:** Si tu driver es antiguo (&lt; 550), llama.cpp (el motor de Ollama) detectará incompatibilidad y usará solo CPU, lo que resultará en un rendimiento muy lento e incluso podría agotar la RAM del host y terminar los procesos.

### 4.1 Instalación del driver NVIDIA (versión 550+)

La forma más segura es usar el repositorio oficial de NVIDIA. Ejecuta estos comandos en orden:

```bash
# 1. Actualiza los repositorios del sistema
apt update && apt upgrade -y

# 2. Descarga el archivo de preferencias de NVIDIA para CUDA
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600

# 3. Descarga e instala el repositorio local de CUDA
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-repo-ubuntu2204-12-2-local_12.2.2-535.104.05-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2204-12-2-local_12.2.2-535.104.05-1_amd64.deb

# 4. Importa la llave GPG de NVIDIA y configura el repositorio
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring_1.0-1_all.deb
sudo apt update

# 5. Instala el driver NVIDIA 550+
sudo apt install -y nvidia-driver-550

# 6. Reinicia el sistema para aplicar los cambios
sudo reboot
```

**Después del reinicio**, verifica que el driver se instaló correctamente:

```bash
nvidia-smi
```

Deberías ver algo como esto (la versión del driver debe ser ≥ 550):

![Verificación del driver NVIDIA](/images/litellm-ollama/18-verificar-driver-nvidia.png)

Si ves el número de versión del driver ≥ 550, **estás listo para continuar.**

### 4.2 Instalación de NVIDIA Container Toolkit

El NVIDIA Container Toolkit es el componente que permite que los contenedores Docker accedan a la GPU del host. Es **obligatorio** para que Ollama pueda usar la tarjeta NVIDIA desde dentro de Docker.

Ejecuta estos comandos en orden:

```bash
# 1. Configura el repositorio de NVIDIA Container Toolkit con autenticación GPG
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# 2. Actualiza los repositorios e instala el toolkit
sudo apt update
sudo apt install -y nvidia-container-toolkit

# 3. Configura Docker para usar el runtime de NVIDIA
sudo nvidia-ctk runtime configure --runtime=docker

# 4. Reinicia Docker para aplicar los cambios
sudo systemctl restart docker
```

### 4.3 Verificación de la instalación

Verifica que Docker ahora tiene acceso a la GPU ejecutando un contenedor de NVIDIA:

```bash
docker run --rm --gpus all nvidia/cuda:12.2.0-runtime-ubuntu22.04 nvidia-smi
```

Deberías ver la información de tu GPU (nota el `GPU Memory Usage`):

![Verificación de acceso a GPU desde Docker](/images/litellm-ollama/19-verificar-acceso-gpu-docker.png)

Si ves correctamente tu GPU en esta salida, **¡la configuración es correcta y tu infraestructura está lista para desplegar Ollama con soporte GPU!** ✅

---

## Paso 5: Configuración y despliegue de la infraestructura (Docker Compose)

Con el driver de NVIDIA y el Container Toolkit listos, es momento de levantar nuestra infraestructura. Utilizaremos Docker Compose para orquestar tres servicios clave: **PostgreSQL** (para la persistencia de LiteLLM), **Ollama** (para la ejecución de modelos locales con GPU) y **LiteLLM** (el proxy de gobernanza).

### 5.1 Obtener los archivos de configuración

Puedes obtener todos los archivos necesarios para este tutorial clonando el repositorio oficial desde GitHub:

```bash
git clone https://github.com/bramendev/proyectos.git
cd proyectos/lite-llm-ollama
```

Esto descargará automáticamente los archivos de configuración (`docker-compose.yml`, `lite-llm-config.yaml`, `.env`, `init-db.sh`, etc.) listos para usar.

### 5.2 Archivos de configuración

Una vez clonado el repositorio, tu estructura de archivos debería verse así:

![Estructura de archivos del repositorio](/images/litellm-ollama/20-estructura-archivos-repo.png)

Levantamos los contenedores en segundo plano ejecutando:

```bash
docker compose up -d
```

Se descargarán e iniciarán los servicios de PostgreSQL, Ollama y LiteLLM:

![Levantando contenedores](/images/litellm-ollama/12-levantando-contenedores.png)

Verificamos que todos los contenedores estén activos y saludables:

```bash
docker compose ps
```

![Verificación de contenedores](/images/litellm-ollama/13-verificacion-contenedores.png)

### 5.3 Acceso al Dashboard de LiteLLM

Una vez que los servicios estén corriendo, podemos acceder a la interfaz web de administración de LiteLLM ingresando la IP pública de tu VPS en el puerto `4000`:

`http://<IP_DE_TU_VPS>:4000/ui/`

Deberías ver la pantalla de inicio de sesión:

![Pantalla de login de LiteLLM](/images/litellm-ollama/14-pantalla-login.png)

Inicia sesión utilizando las credenciales maestras definidas en tu archivo `.env`:

- **Username:** `admin`
- **Password:** `sk-lite-llm-master-key` (o la clave que hayas configurado en `LITELLM_MASTER_KEY`)

Una vez autenticado, tendrás acceso completo al panel de control:

![Dashboard de LiteLLM](/images/litellm-ollama/15-dashboard.png)

### 5.4 Gestión de modelos: Registro en LiteLLM

LiteLLM necesita saber qué modelos tiene Ollama para poder exponerlos a través de su API. Los modelos se registran en el archivo **`lite-llm-config.yaml`** que clonaste del repositorio. Veamos cómo funciona:

```yaml
model_list:
  - model_name: Qwen 3 8B            # ← Nombre visible en la API (lo pones tú)
    litellm_params:
      model: ollama/qwen3:8b          # ← Nombre exacto del modelo en Ollama
      api_base: http://ollama:11434   # ← URL interna de Ollama (siempre igual)
      max_tokens: 4096                # ← Ventana de contexto del modelo
      request_timeout: 300            # ← Timeout en segundos
```

Estos son los modelos que están por defecto en el archivo el repositorio, busca en https://ollama.com/library el modelo que mejor se ajuste a tus necesidades y mapéalo en el archivo.

![Modelos preconfigurados en lite-llm-config.yaml](/images/litellm-ollama/21-modelos-config.png)

Cada modelo que hayas descargado con `ollama pull` debe tener su entrada correspondiente en `model_list`. Veamos de dónde sale cada campo:

| Campo | ¿De dónde lo saco? |
|---|---|
| `model_name` | **Lo inventas tú.** Es el nombre con el que los usuarios llamarán al modelo desde la API (ej. `"Qwen 3 8B"`). |
| `model` | **Es el nombre del modelo en Ollama.** Ejecuta `docker exec lite-llm-ollama ollama list` para ver los modelos descargados. El formato es `ollama/<nombre>:<tag>` (ej. `ollama/qwen3:8b`, `ollama/gemma4:31b`). |
| `api_base` | **Siempre es `http://ollama:11434`**. Es la URL interna de Ollama dentro de la red de Docker, no cambia. |
| `max_tokens` | **Es el límite de contexto del modelo.** Revisa la ficha técnica del modelo en [ollama.com/library](https://ollama.com/library) o en la web del desarrollador (Google, Meta, etc.). Por ejemplo, Qwen 3 8B soporta hasta 32K tokens, pero conviene empezar con 4096. |
| `request_timeout` | **Lo defines según tu paciencia.** 300 segundos (5 min) es un buen valor para modelos grandes. Si el modelo es muy rápido, puedes bajarlo a 120. |

> **💡 Para consultar los modelos descargados en Ollama:**
> ```bash
> docker exec lite-llm-ollama ollama list
> ```
> La salida te mostrará el nombre exacto que debes usar en el campo `model`:

> **💡 Puedes gestionar modelos de dos formas:**
>
> 1. **Vía archivo de configuración (recomendado al inicio):** Edita `lite-llm-config.yaml` directamente y reinicia el contenedor con `docker compose restart litellm`.
> 2. **Vía UI de LiteLLM (una vez en producción):** Desde el Dashboard ve a **Models** → **Add Model**. Los cambios se guardan en la base de datos PostgreSQL. Esto es útil para agregar/quitar modelos sin reiniciar el contenedor.

---

## Paso 6: Descarga y ejecución de modelos de alta capacidad (Gemma 4)

Ahora que la infraestructura está lista, descargaremos y ejecutaremos modelos de lenguaje de alto rendimiento. En este tutorial utilizaremos **Gemma 4 12B** y **Gemma 4 31B**, dos de los modelos abiertos más potentes desarrollados por Google.

### 6.1 Descarga de modelos en Ollama

Para descargar los modelos dentro del contenedor de Ollama, ejecuta los siguientes comandos en tu terminal:

```bash
# Descargar Qwen 2.5 1.5B
docker exec -it lite-llm-ollama ollama pull qwen2.5:1.5b

# Descargar Qwen 3 8B (Ligero y rápido)
docker exec -it lite-llm-ollama ollama pull qwen3:8b

# Descargar Gemma 4 31B (Alta capacidad y razonamiento complejo)
docker exec -it lite-llm-ollama ollama pull gemma4:31b
```

> **⚠️ Importante:** Cada vez que descargues un nuevo modelo con `ollama pull`, debes **registrarlo en el archivo `lite-llm-config.yaml`** para que LiteLLM pueda exponerlo. Solo los modelos listados en `model_list` estarán disponibles a través de la API. Revisa la [sección 5.4](#54-gestión-de-modelos-registro-en-litellm) para ver cómo hacerlo.

### 6.2 Ejecución y verificación de uso de GPU

Para garantizar que Ollama está utilizando la GPU de NVIDIA de forma correcta y no la CPU, iniciaremos una sesión interactiva con el modelo de 12B:

```bash
docker exec -it lite-llm-ollama ollama run qwen3:8b
```

![Sesión interactiva con Ollama](/images/litellm-ollama/22-sesion-interactiva-ollama.png)

Mientras realizas preguntas en la sesión interactiva, abre una segunda terminal SSH en tu VPS y ejecuta `nvidia-smi` para monitorear el uso de recursos en tiempo real:

```bash
watch -n1 nvidia-smi
```

Deberías ver que el proceso `llama-server` está activo en la GPU y que el consumo de VRAM aumenta significativamente, confirmando que la aceleración por hardware está funcionando al 100%. ✅

![Monitoreo de GPU con nvidia-smi](/images/litellm-ollama/23-monitoreo-gpu-nvidia-smi.png)

---

## Paso 7: Gobernanza de acceso y gestión de API Keys con LiteLLM

Una de las mayores ventajas de usar LiteLLM en producción es la capacidad de controlar quién y cómo consume tus modelos locales. A continuación te guío paso a paso por todo el panel de administración.

### 7.1 Acceso al Dashboard de LiteLLM

Si aún no lo has hecho, accede al panel de administración desde tu navegador:

```
http://<IP_DE_TU_VPS>:4000/ui/
```

![Pantalla de inicio de sesión de LiteLLM](/images/litellm-ollama/14-pantalla-login.png)

Inicia sesión con las credenciales maestras que definiste en el archivo `.env`:

- **Username:** `admin`
- **Password:** `sk-lite-llm-master-key` (o el valor de `LITELLM_MASTER_KEY`)

![Login con credenciales maestras](/images/litellm-ollama/24-pantalla-login-credenciales.png)

Una vez dentro verás el panel principal con las secciones: **API Keys**, **Models**, **Spend Logs** y **Team**.

![Dashboard principal de LiteLLM](/images/litellm-ollama/25-dashboard-principal.png)
---

### 7.2 Creación de API Keys personalizadas

Las API Keys son la forma de identificar y controlar a cada usuario o aplicación que consume tus modelos.

**Paso a paso:**

1. En el menú lateral izquierdo, haz clic en **API Keys**.
2. Haz clic en el botón **+ Create New Key** (esquina superior derecha).
3. Se abrirá un formulario. Completa los campos:

![Formulario para crear nueva API Key](/images/litellm-ollama/26-formulario-crear-api-key.png)

| Campo | Qué poner | Ejemplo |
|---|---|---|
| **Key Name** | Un nombre descriptivo para identificar a quién pertenece la llave | `desarrollo-frontend`, `usuario-juan`, `bot-produccion` |
| **Models** | Selecciona qué modelos puede usar esta llave. Si no seleccionas ninguno, podrá usar todos. | `Qwen 3 8B` |
| Key Type | Tipo de llave a asignar | AI APIs |
| **Max Budget (USD)** | Límite máximo de gasto en dólares. Cuando se alcanza, la llave se desactiva automáticamente | `50.00` |
| **Reset Budget** | Período en el que aplica el presupuesto: `daily`, `weekly`, `monthly` o `none` | `monthly` |
| **Tokens per minute (TPM)** | Límite de tokens por minuto para evitar saturación | `100000` |
| **Requests per minute (RPM)** | Límite de peticiones por minuto | `60` |
| **Metadata** | Información adicional en formato JSON (opcional) | `{"department": "engineering"}` |

![Formulario de API Key completado](/images/litellm-ollama/27-formulario-api-key-completado.png)

4. Haz clic en **Create Key**.

![Creando la API Key](/images/litellm-ollama/28-creando-api-key.png)

5. **¡Copia la llave generada inmediatamente!** Solo se muestra una vez. Tiene el formato `sk-...`.

![API Key generada exitosamente](/images/litellm-ollama/29-api-key-generada.png)


> ⚠️ **Importante:** La llave no se vuelve a mostrar. Si la pierdes, tendrás que revocarla y crear una nueva.

---

### 7.3 Listado y administración de API Keys

En la sección **API Keys** puedes ver todas las llaves creadas, su estado y consumo:

![Listado de API Keys](/images/litellm-ollama/30-listado-api-keys.png)

Desde aquí puedes:

- **🔍 Ver el detalle** de cada llave: total gastado, modelos usados, últimas peticiones.
- **✏️ Editar** los límites de una llave existente (presupuesto, modelos, rate limits).
- **🔴 Revocar** una llave para desactivarla al instante.
- **🔄 Regenerar** una llave si se comprometió.

![Detalle de API Key](/images/litellm-ollama/31-detalle-api-key.png)

![Editar y revocar API Key](/images/litellm-ollama/32-editar-revocar-api-key.png)
---

### 7.4 Monitoreo de gastos (Spend Logs)

La sección **Spend Logs** te muestra el historial detallado de consumo de cada API Key:

![Historial de gastos (Spend Logs)](/images/litellm-ollama/33-historial-spend-logs.png)

Aquí puedes ver:

| Columna | Descripción |
|---|---|
| **Key Alias** | Nombre de la llave que hizo la petición |
| **Model** | Modelo utilizado |
| **Tokens** | Cantidad de tokens consumidos (prompt + completion) |
| **Time** | Fecha y hora exacta de la petición |

---

### 7.5 Gestión de equipos (Teams)

LiteLLM permite agrupar API Keys en equipos para facilitar la administración de presupuestos y permisos.

**Paso a paso para crear un equipo:**

1. Ve a la sección **Teams** en el menú lateral.
2. Haz clic en **+ Create Team**.
3. Completa los campos:

![Formulario para crear equipo](/images/litellm-ollama/34-formulario-crear-equipo.png)

| Campo | Descripción |
|---|---|
| **Team Name** | Nombre del equipo (ej. `Backend`, `Data Science`, `Frontend`) |
| **Models** | Modelos a los que tendrá acceso el equipo |
| **Max Budget (USD)** | Presupuesto máximo compartido para todo el equipo |
| **Reset Budget** | Período del presupuesto (`daily`, `weekly`, `monthly`) |

4. Haz clic en **Create**.
5. Luego, al crear una API Key, puedes asignarla a este equipo. La llave heredará los permisos y el presupuesto del equipo.

![Equipo creado exitosamente](/images/litellm-ollama/35-equipo-creado.png)
---

### 7.6 Resumen visual del flujo de gobernanza

Para que entiendas cómo fluye cada petición a través de LiteLLM:

<div style="margin: 3rem 0; font-family: 'Ubuntu Mono', monospace;">
  <!-- Usuario/App -->
  <div style="text-align: center; margin-bottom: 2rem;">
    <div style="display: inline-block; padding: 1rem 2rem; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 8px; color: white; font-weight: 600; font-size: 1.1rem; box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4);">
      📱 Usuario/App
    </div>
  </div>

  <!-- Arrow and Request -->
  <div style="text-align: center; margin-bottom: 2rem;">
    <div style="font-size: 2rem; color: #667eea; margin-bottom: 0.5rem;">↓</div>
    <div style="display: inline-block; background: rgba(102, 126, 234, 0.1); border-left: 3px solid #667eea; padding: 0.75rem 1rem; border-radius: 4px; color: #667eea; font-size: 0.9rem; max-width: 400px;">
      <code>POST /v1/chat/completions</code><br/>
      <code>Authorization: Bearer sk-xxx</code>
    </div>
  </div>

  <!-- LiteLLM Proxy -->
  <div style="margin-bottom: 2rem;">
    <div style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); border-radius: 12px; padding: 2rem; color: white; box-shadow: 0 12px 32px rgba(245, 87, 108, 0.3);">
      <div style="font-size: 1.3rem; font-weight: 700; margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.5rem;">
        🔐 LiteLLM Proxy (Gobernanza)
      </div>
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; font-size: 0.95rem; line-height: 1.8;">
        <div>✅ Valida la API Key</div>
        <div>✅ Verifica presupuesto</div>
        <div>⚙️ Verifica rate limits</div>
        <div>📊 Registra consumo</div>
        <div>🔄 Reenvía a Ollama</div>
        <div>💾 Almacena logs en DB</div>
      </div>
      <div style="margin-top: 1rem; padding-top: 1rem; border-top: 1px solid rgba(255,255,255,0.3); color: rgba(255,255,255,0.9); font-size: 0.85rem; font-style: italic;">
        ✨ Autentica, valida, autoriza y registra cada petición
      </div>
    </div>
  </div>

  <!-- Arrow down -->
  <div style="text-align: center; margin: 2rem 0;">
    <div style="font-size: 2rem; color: #667eea;">↓</div>
  </div>

  <!-- Ollama GPU -->
  <div style="margin-bottom: 2rem;">
    <div style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); border-radius: 12px; padding: 2rem; color: white; box-shadow: 0 12px 32px rgba(79, 172, 254, 0.3);">
      <div style="font-size: 1.3rem; font-weight: 700; margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.5rem;">
        🚀 Ollama (GPU NVIDIA)
      </div>
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; font-size: 0.95rem; line-height: 1.8;">
        <div>⚡ Ejecuta el modelo LLM</div>
        <div>🧠 Procesa con GPU (CUDA)</div>
        <div>💬 Genera la respuesta</div>
        <div>📤 Devuelve el resultado</div>
      </div>
    </div>
  </div>

  <!-- Arrow back -->
  <div style="text-align: center; margin: 2rem 0;">
    <div style="font-size: 2rem; color: #667eea;">↑</div>
  </div>

  <!-- Response back to user -->
  <div style="text-align: center;">
    <div style="font-size: 2rem; color: #667eea; margin-bottom: 0.5rem;">↑</div>
    <div style="display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 8px; padding: 1rem 2rem; color: white; font-weight: 600; font-size: 1.1rem; box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4);">
      📬 Respuesta (JSON)
    </div>
  </div>
</div>

---

## Paso 8: Integración y pruebas de consumo de la API

Una vez generada tu API Key personalizada, puedes consumir tus modelos locales utilizando cualquier cliente o librería compatible con la API de OpenAI.

### 8.1 Prueba rápida con curl

```bash
curl http://<IP_DE_TU_VPS>:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-tu-api-key-generada" \
  -d '{
    "model": "Gemma 4 31B",
    "messages": [
      {"role": "user", "content": "Hola, ¿cuál es la capital de Francia?"}
    ],
    "temperature": 0.7
  }'
```

![Prueba de consumo de API con curl](/images/litellm-ollama/36-prueba-curl.png)

### 8.2 Integración en Python

```python
from openai import OpenAI

# Configura el cliente apuntando a tu proxy de LiteLLM
client = OpenAI(
    api_key="sk-tu-api-key-generada",
    base_url="http://<IP_DE_TU_VPS>:4000/v1"
)

response = client.chat.completions.create(
    model="Gemma 4 31B",
    messages=[
        {"role": "system", "content": "Eres un asistente de IA útil y conciso."},
        {"role": "user", "content": "Explica brevemente qué es Docker."}
    ]
)

print(response.choices[0].message.content)
```

---

## 🏁 Conclusión

¡Felicidades! Has desplegado con éxito una infraestructura de nivel de producción para modelos de lenguaje de código abierto. 

Gracias a **Ollama**, aprovechas al máximo el rendimiento de tu GPU dedicada NVIDIA RTX 4000 Ada, y con **LiteLLM** tienes un control absoluto sobre quién, cómo y cuánto se consumen tus recursos de inteligencia artificial. Esta arquitectura es ideal para empresas y equipos de desarrollo que buscan escalar sus aplicaciones de IA manteniendo la privacidad de sus datos y el control de sus presupuestos.

---

## 📖 Glosario para No Técnicos (Explicado para Dummies)

Si algunos términos de esta guía te sonaron a "chino", no te preocupes. Aquí tienes una explicación sencilla y amigable de los conceptos más extraños que usamos:

* <span id="glosario-llm">**LLM (Large Language Model / Modelo de Lenguaje Grande):**</span> Es el "cerebro" de la Inteligencia Artificial. Imagínalo como un predictor de texto gigante y súper inteligente que ha leído casi todo el internet y sabe cómo responderte de forma coherente (como ChatGPT, Gemma o Llama).
* <span id="glosario-ollama">**Ollama:**</span> Es el programa que nos permite "instalar" y correr esos cerebros de IA directamente en nuestra propia computadora o servidor, sin depender de internet ni de empresas externas.
* <span id="glosario-litellm">**LiteLLM:**</span> Es el "policía de tráfico" y administrador. Se encarga de recibir las preguntas de los usuarios, verificar que tengan permiso (usando una API Key), controlar que no gasten de más y enviarle la pregunta a Ollama para que la responda.
* <span id="glosario-gpu">**GPU (Graphics Processing Unit / Tarjeta Gráfica):**</span> Es el motor ultra-rápido que hace que la IA responda al instante. Aunque originalmente se inventaron para videojuegos, las GPUs son perfectas para la IA porque pueden hacer millones de cálculos matemáticos al mismo tiempo.
* <span id="glosario-vram">**VRAM (Video RAM):**</span> Es la memoria súper rápida que tiene la tarjeta gráfica (GPU). Imagínala como la "mesa de trabajo" de la IA: entre más grande sea la mesa (más VRAM), más grandes y complejos serán los libros (modelos) que la IA puede abrir y leer al mismo tiempo.
* <span id="glosario-tokens">**Tokens:**</span> Son los "pedacitos" en los que la IA divide las palabras para poder procesarlas. Una palabra promedio equivale a 1 o 1.5 tokens. Cuando la IA te responde, la velocidad se mide en "tokens por segundo" (básicamente, cuántas sílabas o palabras escribe por segundo).
* <span id="glosario-cuantizacion">**Cuantización (Q4, Q5, etc.):**</span> Es una técnica para "comprimir" un modelo de IA para que ocupe menos espacio y use menos memoria, sin perder casi nada de su inteligencia. Es el equivalente a convertir una canción pesada en formato WAV a un archivo MP3 ligero.
* <span id="glosario-api-key">**API Key:**</span> Es una contraseña especial (como una llave digital) que le das a una aplicación o usuario para que pueda usar tu servidor de IA. Te permite saber exactamente quién está haciendo las preguntas y ponerle límites para que no te saturen el servidor.
* <span id="glosario-docker">**Docker / Contenedor:**</span> Imagina que quieres llevar una cocina completa a otra casa. En lugar de desarmar todo, metes la cocina entera dentro de una caja mágica (contenedor) donde todo ya está conectado y funciona. Docker es la herramienta que mueve y enciende esas cajas en cualquier servidor de forma limpia.
* <span id="glosario-vps">**VPS (Virtual Private Server / Servidor Virtual Privado):**</span> Es una computadora que alquilas en internet (en la nube) que está encendida las 24 horas del día, los 7 días de la semana, para que tus aplicaciones siempre estén disponibles.
* <span id="glosario-ssh">**SSH:**</span> Es un "túnel secreto y seguro" que usas desde tu computadora para conectarte y controlar la computadora que alquilaste en internet (el VPS) mediante comandos de texto.
* <span id="glosario-htop">**htop:**</span> Es el "Administrador de Tareas" de Linux. Una pantalla de colores que te muestra qué tan cansado está el procesador (CPU) y cuánta memoria RAM le queda libre a tu servidor.