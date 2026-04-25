# ProChat v4.4.2 (Latest Release)

Esta versión representa un salto significativo en la arquitectura del addon, pasando de un sistema de filtrado estático a uno **dinámico y bilingüe**, con una interfaz de usuario (UI) completamente optimizada para el rendimiento y la personalización.

---

## 🚀 Novedades y Mejoras Principales (vs v4.2.3)

### 🌍 Soporte Bilingüe Nativo (Selector de Idioma)
* **Detección Automática:** El addon ahora detecta el idioma del cliente (Español/Inglés) en la primera instalación.
* **Selector en Tiempo Real:** Se ha integrado un menú desplegable en la interfaz para cambiar el idioma de toda la UI y los mensajes del sistema instantáneamente, sin necesidad de `/reload`.

### 🔍 Motor de Búsqueda Avanzado (Lógica OR)
* **Filtrado por Palabras Clave:** Se ha implementado un sistema de búsqueda inteligente que permite filtrar mensajes y listas de bandas usando múltiples términos.
* **Lógica No Excluyente:** A diferencia de versiones anteriores, ahora si buscas `ICC TOC`, el addon mostrará resultados que contengan **cualquiera** de los dos términos, mejorando drásticamente la visibilidad de grupos.

### 📊 Gestión de Bandas (RaidWin) Mejorada
* **Listado de Líderes Activos:** Se ha perfeccionado la ventana derecha (`RaidWin`) para agrupar líderes por mazmorra de forma colapsable.
* **Sincronización Total:** La lista de líderes ahora respeta los mismos filtros de búsqueda que el chat principal, asegurando una experiencia unificada.

### 🎨 Interfaz de Usuario (UI) Moderna y Limpia
* **Optimización de Espacio:** El selector de idiomas y el checkbox de opciones se han integrado en la **barra de título**, liberando área útil de lectura.
* **Ventanas de Bienvenida y Créditos:** Se añadieron diálogos interactivos con instrucciones claras y comandos disponibles, traducidos íntegramente.
* **Persistencia de Configuración:** Mejoras en la base de datos `ProChatDB` para recordar posiciones, escala, idioma y filtros entre sesiones.

### ⚙️ Mejoras Técnicas y Estabilidad
* **Gestión de Memoria:** Optimización del evento `CHAT_MSG_CHANNEL` para reducir el impacto de CPU en servidores de alta población.
* **Control de Spam Dinámico:** El modo "Ocultar Spam" (*Hide Grays*) es ahora más selectivo con los mensajes de canales globales.

---

## 🛠️ Instalación y Actualización

1. Descarga los archivos `ProChat.lua` y `ProChat.toc`.
2. Copia la carpeta en su directorio correspondiente: 
   `Interface\AddOns\ProChat`
3. **Recomendación:** Si actualizas desde la versión 4.2.3 o inferior, utiliza el comando `/pc reset` una vez dentro del juego para limpiar la caché de la base de datos antigua.

---

## ⌨️ Comandos Disponibles

| Comando | Acción |
| :--- | :--- |
| `/pc` o `/prochat` | Abre o cierra el panel principal de filtrado. |
| `/pc reset` | Restablece las ventanas, tamaños y reinicia el idioma. |

---

# ProChat v4.2.3 (Legacy Stable) - World of Warcraft 3.3.5a

Asistente avanzado de filtrado de chat y antispam para jugadores de servidores privados 3.3.5 (TrinityCore/AzerothCore).

### 🚀 Características de la Rama 4.2
* **Filtro de Spam Inteligente:** Tiempos de espera configurables entre mensajes.
* **Monitoreo de Líderes de Raid:** Ventana independiente para conteo de grupos.
* **Identificación Visual:** Colores de clase en nombres y etiquetas de mazmorra automáticas.
* **Sistema Multicanal:** Soporte para Posada, Comercio, General, Hermandad, Decir y Gritar.

---
_Desarrollado con pasión para la comunidad de World of Warcraft 3.3.5._
