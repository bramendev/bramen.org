---
title: "Docker Hello World: Tu primer contenedor en 5 minutos"
date: 2026-07-11
description: "Aprende a ejecutar tu primer contenedor de Docker con el ejemplo clásico de Hello World"
tags: ["docker", "contenedores", "tutorial", "practicante"]
icon: "🐳"
author: "Brayan Herrera"
---

## Introducción

Docker es una de las herramientas más importantes en el desarrollo de software moderno. En este tutorial aprenderás a ejecutar tu primer contenedor de Docker con el clásico ejemplo de "Hello World".

### ¿Qué es Docker?

Docker es una plataforma que permite desarrollar, distribuir y ejecutar aplicaciones en contenedores. Los contenedores son unidades ligeras y portables que incluyen todo lo necesario para ejecutar una aplicación.

## Paso 1: Verificar que Docker está instalado

Antes de comenzar, verifica que Docker esté instalado en tu sistema:

```bash
docker --version
```

Deberías ver algo como:

```
Docker version 24.0.7, build afdd53b
```

Si no tienes Docker instalado, puedes descargarlo desde [docker.com](https://www.docker.com/products/docker-desktop/).

## Paso 2: Ejecutar Hello World

Ah viene la parte divertida. Ejecuta el siguiente comando:

```bash
docker run hello-world
```

Este comando hará lo siguiente:

1. **Buscará** la imagen `hello-world` en tu máquina local
2. **Descargará** la imagen desde Docker Hub si no la tienes
3. **Ejecutará** el contenedor
4. **Mostrará** un mensaje de bienvenida

### Salida esperada

```
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image.
 4. The Docker daemon streamed the output to the Docker client.
```

## Paso 3: Entender qué pasó

Veamos paso a paso lo que sucedió:

| Paso | Descripción |
|------|-------------|
| 1 | El cliente Docker se comunicó con el daemon de Docker |
| 2 | El daemon descargó la imagen `hello-world` desde Docker Hub |
| 3 | El daemon creó un nuevo contenedor a partir de esa imagen |
| 4 | El daemon envió el mensaje de salida al cliente |

## Paso 4: Comandos útiles

### Ver imágenes descargadas

```bash
docker images
```

### Ver contenedores (incluidos los que ya terminaron)

```bash
docker ps -a
```

### Eliminar una imagen

```bash
docker rmi hello-world
```

### Volver a descargar y ejecutar

```bash
docker pull hello-world
docker run hello-world
```

## Conclusión

¡Felicidades! Acabas de ejecutar tu primer contenedor de Docker. Este es solo el comienzo. En futuros tutoriales aprenderás a:

- Crear tus propias imágenes
- Ejecutar aplicaciones en contenedores
- Usar Docker Compose para múltiples contenedores
- Desplegar aplicaciones en producción

## ¿Quieres ver más?

Suscríbete a mi canal de YouTube **[@BramenDev](https://www.youtube.com/@BramenDev)** para más tutoriales de Docker y desarrollo de software.
