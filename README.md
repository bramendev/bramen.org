# bramen.org 🚀

Sitio web personal de Brayan Herrera construido con [Hugo](https://gohugo.io/).

## 🎨 Características

- **Tema tech/IT oscuro** con fuente Ubuntu
- **Diseño responsive** para todos los dispositivos
- **Sección de tutoriales** con paginación
- **Integración con YouTube** para contenido en video
- **Terminal animada** en la página de inicio
- **Navegación suave** con efectos visuales

## 📁 Estructura del proyecto

```
bramen.org/
├── content/
│   ├── about.md              # Página "Acerca de"
│   └── tutorials/            # Sección de tutoriales
│       ├── _index.md         # Índice de tutoriales
│       └── configurar-entorno-linux.md  # Tutorial de ejemplo
├── themes/
│   └── bramen-theme/         # Tema personalizado
│       ├── assets/css/
│       │   └── style.css     # Estilos principales
│       └── layouts/
│           ├── home/         # Página de inicio
│           ├── tutorials/    # Layouts de tutoriales
│           ├── pages/        # Páginas estáticas
│           └── partials/     # Componentes reutilizables
├── hugo.toml                 # Configuración de Hugo
└── README.md
```

## 🚀 Cómo usar

### Requisitos previos

- [Hugo](https://gohugo.io/getting-started/installing/) (versión 0.123+ extended)
- Git

### Desarrollo local

```bash
# Navegar al directorio del proyecto
cd bramen.org

# Iniciar el servidor de desarrollo
hugo server

# Abrir en el navegador
# El sitio estará disponible en http://localhost:1313
```

### Crear un nuevo tutorial

```bash
# Crear un nuevo archivo de tutorial
hugo new tutorials/mi-nuevo-tutorial.md

# Editar el archivo y agregar contenido
# Luego iniciar el servidor para ver los cambios
hugo server
```

### Construir para producción

```bash
# Construir el sitio estático
hugo --minify

# Los archivos generados estarán en la carpeta public/
```

## ✏️ Personalización

### Cambiar información personal

Edita `hugo.toml` para modificar:

```toml
[params]
  author = "Tu Nombre"
  description = "Tu descripción"
  youtubeChannel = "@tucanal"
  github = "https://github.com/tuusuario"
```

### Agregar más tutoriales

Cada tutorial es un archivo Markdown en `content/tutorials/` con frontmatter:

```yaml
---
title: "Título del Tutorial"
date: 2026-07-11
description: "Descripción breve"
tags: ["tag1", "tag2"]
icon: "🎯"
author: "Brayan Herrera"
---

## Contenido del tutorial

Escribe tu contenido aquí...
```

### Cambiar colores del tema

Edita las variables CSS en `themes/bramen-theme/assets/css/style.css`:

```css
:root {
    --primary-color: #00bcd4;
    --secondary-color: #7c4dff;
    --accent-color: #00e676;
}
```

## 📝 Menú de navegación

El menú se configura en `hugo.toml`:

```toml
[menu]
  [[menu.main]]
    identifier = "home"
    name = "Inicio"
    pageRef = "/"
    weight = 10
```

## 🎯 Secciones del sitio

1. **Inicio** - Presentación con terminal animada, stats y tutoriales recientes
2. **Tutoriales** - Lista de todos los tutoriales y artículos
3. **YouTube** - Enlace directo al canal de YouTube
4. **Acerca de** - Página con información personal

## 🛠️ Tecnologías

- **Hugo** - Generador de sitios estáticos
- **CSS3** - Estilos con variables CSS y animaciones
- **Font Awesome** - Iconos
- **Google Fonts** - Fuente Ubuntu

## 📄 Licencia

Este proyecto es de código abierto.

---

Hecho con ❤️ por [Brayan Herrera](https://bramen.org)
