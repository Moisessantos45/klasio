# Klasio
### *Galería privada de clases con OCR, audio y exportación para estudiantes*

---

## El Origen de la Idea

Esta aplicación nació de una necesidad real y cotidiana en el día a día universitario y escolar:

> *"En mis clases tengo que tomar constantemente fotos de las diapositivas o del pizarrón con el contenido que nos imparten para luego poder pasarlo a mi libreta y estudiar.  
> Sin embargo, todas las fotos se iban a la galería principal de mi teléfono; como tenía varias materias al día, todo terminaba mezclado y empalmado. Era muy tedioso y frustrante tener que buscar foto por foto para saber dónde terminaba una clase y empezaba otra.  
> Por ello decidí crear **Klasio**: para tener un control total, una galería 100% privada y una mejor distribución y aprovechamiento de todo el material de estudio."*

---

## Concepto Principal

**Klasio** es una aplicación móvil (Android) diseñada específicamente para estudiantes que necesitan capturar fotos de sus clases (pizarrón, presentaciones, fórmulas, apuntes) y mantenerlas perfectamente ordenadas por materia y fecha, **sin que se mezclen con el resto de fotos de su galería personal**.

---

## El Problema que Resuelve

1. **Galería saturada y desorganizada:** Las fotos de clase se mezclan con fotos personales, memes, viajes y capturas de pantalla cotidianas.
2. **Pérdida de tiempo:** Es difícil encontrar el contenido exacto de una materia o fecha de examen específica.
3. **Pérdida de orden y contexto:** Al tomar varias fotos por día de diferentes asignaturas, se pierde la secuencia del contenido visto en el aula.
4. **Barrera para transcribir y repasar:** Transcribir a mano textos largos desde fotos pequeñas toma mucho tiempo.

---

## ¿Cómo Funciona?

* **Almacenamiento en Sandbox Privado:** Las imágenes capturadas o importadas se guardan en el directorio privado interno de la app (sandbox de Android). **No aparecen en la galería pública del dispositivo**, evitando que se empalmen con tus fotos personales.
* **Flujo directo al capturar:** Tomas la foto o la importas y seleccionas de inmediato a qué materia pertenece.
* **Organización automática y jerárquica:** Klasio clasifica cada captura por materia, fecha, colores distintivos y etiquetas temáticas.

---

## Funcionalidades Clave

### 1. Galería Privada y Jerárquica por Materias
* **Carpetas por Materia:** Crea carpetas personalizadas con nombres, iconos temáticos y colores únicos.
* **Sistema de Subcarpetas Recursivas:** Crea subcarpetas dentro de carpetas (por ejemplo: *Materia > Unidad 1 > Exámenes*) en niveles ilimitados para una organización milimétrica.
* **Filtrado por Etiquetas:** Asigna tags temáticos (*Tareas, Exámenes, Proyectos, Pizarras, etc.*) para encontrar contenido al instante.

### 2. Extracción de Texto (OCR)
* **Digitalización Inmediata:** Convierte automáticamente fotos de pizarrones o diapositivas en texto editable.
* **Escaneo Masivo por Carpeta:** Opción para extraer el texto de **todas las capturas de una materia o carpeta** en un solo documento consolidado.
* **Copia y Búsqueda:** Copia texto seleccionado, busca definiciones y estudia sin tener que transcribir manualmente.

### 3. Texto a Voz (Audio / TTS)
* **Reproducción de Apuntes en Voz Alta:** Escucha las transcripciones de tus clases con velocidad y tono ajustables.
* **Estudio en Movimiento:** Ideal para repasar el contenido mientras caminas, viajas en transporte público o descansas la vista.

### 4. Exportación y Compartir
* **Exportación a `.txt`:** Guarda y exporta el texto extraído a archivos planos listos para usar en Word, Notion, Obsidian o imprimir.
* **Compartir:** Comparte apuntes y transcripciones fácilmente con tus compañeros de clase.

### 5. Personalización y Experiencia Visual
* **Paleta de Colores Curada:** Asigna colores visuales contrastantes a cada materia para rápida identificación.
* **Catálogo de Iconos Académicos:** Iconos para ciencias, matemáticas, programación, idiomas, medicina, arte y más.
* **Dashboard y Estadísticas:** Resumen de carpetas recientes, últimas capturas y conteos globales en la pantalla principal.

---

## Diferenciadores

| Característica | Galería Convencional | Klasio |
| :--- | :--- | :--- |
| **Separación de fotos personales** | ❌ No (se mezcla todo) | ✅ Sí (Sandbox 100% privado) |
| **Organización por Materias y Subcarpetas** | ❌ Tediosa y manual | ✅ Diseñada para el flujo de clase |
| **Extracción de texto (OCR)** | ❌ No integrada | ✅ Individual y por carpeta completa |
| **Lectura en voz alta (TTS)** | ❌ No disponible | ✅ Integrado para repasar escuchando |
| **Exportación de apuntes** | ❌ No disponible | ✅ Exportación a `.txt` y compartir |

---

## Público Objetivo

* **Estudiantes universitarios y de preparatoria** que asisten a clases diarias y dependen de capturas del pizarrón y diapositivas.
* **Estudiantes de carreras técnicas o científicas** con alta carga de diagramas, fórmulas y apuntes visuales.
* **Cualquier persona en capacitación constante** que busque orden, transcripción rápida y privacidad para su material de estudio.

---

## Stack Tecnológico

* **Framework:** [Flutter](https://flutter.dev/)
* **Lenguaje:** [Dart](https://dart.dev/)
* **Gestión de Estado:** [Riverpod](https://riverpod.dev/) (`AsyncNotifier`, `FutureProvider.family`)
* **Base de Datos Local:** [SQLite](https://pub.dev/packages/sqflite) (`sqflite` con claves foráneas autorreferenciales y cascada)
* **Servicios Nativos:**
  * **OCR / Visión Artificial:** Reconocimiento de texto en imágenes.
  * **TTS (Text-to-Speech):** Síntesis de voz para lectura de apuntes.
  * **Image Optimization:** Compresión y escalado eficiente de imágenes para optimizar almacenamiento.

---

## Estructura del Proyecto

```text
lib/
├── config/             # Colores, temas, rutas, iconos y datos constantes
├── core/               # Base de datos SQLite y servicios nativos (OCR, TTS)
├── data/               # Datasources, mappers y modelos de datos
├── domain/             # Entidades y lógica del dominio
├── presentation/       # Vistas, pantallas, providers (Riverpod) y widgets
└── main.dart           # Punto de entrada de la aplicación
```
