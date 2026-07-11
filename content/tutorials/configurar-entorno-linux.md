---
title: "Cómo configurar tu entorno de desarrollo en Linux"
date: 2026-07-10
description: "Guía completa para configurar un entorno de desarrollo profesional en Ubuntu"
tags: ["linux", "ubuntu", "desarrollo", "setup"]
icon: "🐧"
author: "Brayan Herrera"
---

## Introducción

Configurar un entorno de desarrollo eficiente es fundamental para cualquier programador. En esta guía te mostraré cómo configurar un entorno profesional en Ubuntu.

### Paso 1: Actualizar el sistema

Primero, siempre es importante actualizar nuestro sistema:

```bash
sudo apt update && sudo apt upgrade -y
```

### Paso 2: Instalar herramientas básicas

```bash
sudo apt install -y git curl wget vim build-essential
```

### Paso 3: Configurar Git

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
git config --global core.editor "vim"
```

### Paso 4: Instalar un editor de código

Te recomiendo [VS Code](https://code.visualstudio.com/) o cualquier editor que te guste.

## Conclusión

Con estos pasos básicos ya tienes un entorno listo para desarrollar. ¡Próximamente más guías!
