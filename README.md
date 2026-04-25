ProChat v4.4.2 (Latest Release)
Esta versión representa un salto significativo en la arquitectura del addon, pasando de un sistema de filtrado estático a uno dinámico y bilingüe, con una interfaz de usuario (UI) completamente optimizada para el rendimiento y la personalización.

🚀 Novedades y Mejoras Principales (vs v4.2.3)
🌍 Soporte Bilingüe Nativo (Selector de Idioma)
Detección Automática: El addon ahora detecta el idioma del cliente (Español/Inglés) en la primera instalación.

Selector en Tiempo Real: Menú desplegable integrado para cambiar el idioma de toda la UI y mensajes del sistema instantáneamente, sin necesidad de /reload.

🔍 Motor de Búsqueda Avanzado (Lógica OR)
Filtrado por Palabras Clave: Sistema de búsqueda inteligente que permite filtrar mensajes y listas de bandas usando múltiples términos.

Lógica No Excluyente: Si buscas ICC TOC, el addon mostrará resultados que contengan cualquiera de los dos términos, optimizando la búsqueda de grupos.

📊 Gestión de Bandas (RaidWin) Mejorada
Listado de Líderes Activos: Ventana derecha perfeccionada para agrupar líderes por mazmorra de forma colapsable.

Sincronización Total: La lista de líderes ahora respeta los mismos filtros de búsqueda que el chat principal.

🎨 Interfaz de Usuario (UI) Moderna y Limpia
Optimización de Espacio: El selector de idiomas y el checkbox de opciones se han integrado en la barra de título, liberando área de visualización.

Ventana de Bienvenida y Créditos: Nuevas ventanas interactivas con instrucciones claras, traducidas según el idioma seleccionado.

Persistencia de Configuración: Mejoras en ProChatDB para recordar posiciones, escala, idioma y filtros entre sesiones.

⚙️ Mejoras Técnicas y Estabilidad
Gestión de Memoria: Optimización del evento CHAT_MSG_CHANNEL para reducir el impacto de CPU en reinos de alta población.

Control de Spam Dinámico: Modo "Ocultar Spam" (Hide Grays) más preciso para filtrar mensajes irrelevantes.

🛠️ Instalación y Actualización
Descarga los archivos ProChat.lua y ProChat.toc.

Copia la carpeta en Interface\AddOns\ProChat.

Importante: Si actualizas desde la 4.2.3, usa el comando /pc reset para limpiar configuraciones antiguas.

⌨️ Comandos Disponibles
/pc o /prochat: Abre/Cierra el panel principal.

/pc reset: Restablece ventanas y configuración de idioma.

ProChat v4.2.3 (Legacy Stable) - World of Warcraft 3.3.5a
Asistente avanzado de filtrado de chat y antispam para jugadores de servidores privados 3.3.5 (TrinityCore/AzerothCore).

🚀 Características Principales
Filtro de Spam Inteligente: Tiempos de espera personalizados entre mensajes.

Monitoreo de Líderes de Raid: Ventana independiente para conteo de grupos activos.

Identificación Visual: Colores de clase y etiquetas de mazmorra coloreadas.

Sistema Multicanal: Soporte para Posada/Taberna, Comercio, General, Hermandad, Decir y Gritar.

Desarrollado con pasión para la comunidad de World of Warcraft 3.3.5.
