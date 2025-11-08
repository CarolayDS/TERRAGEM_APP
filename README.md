
# 🌱 TerraGem – Aplicativo móvil para la Interpretación de Análisis de Suelo

**Aplicación móvil desarrollada en Flutter e Inteligencia Artificial (IA)** para la **interpretación automatizada de análisis de suelo agrícolas**, con el propósito de apoyar la toma de decisiones agronómicas sostenibles.

> Proyecto de investigación desarrollado en la **Universidad Nacional de Cañete (UNDC)**, orientado a la transformación digital del sector agrícola mediante el uso de tecnologías accesibles y de alto impacto.

---

## 🧠 Descripción del Proyecto

**TerraGem** es una herramienta móvil que permite a los usuarios **interpretar resultados de análisis de suelo** mediante un modelo de **inteligencia artificial generativa** (Google Gemini).  
A partir de los valores físico-químicos del suelo, la app genera **recomendaciones de manejo personalizadas** según el tipo de cultivo, el clima y las condiciones del terreno.

El sistema integra múltiples servicios tecnológicos:

- **Flutter:** desarrollo multiplataforma para Android e iOS.  
- **Supabase:** backend en la nube para autenticación y almacenamiento de datos.  
- **Gemini API:** inteligencia artificial para la interpretación semántica del análisis de suelo.  
- **OpenWeatherMap:** módulo de pronóstico climático en tiempo real.  
- **Google Maps API:** visualización geográfica y localización de tiendas agrícolas.

---

## 🌾 Funcionalidades Principales

- 🔍 **Interpretación automática** de parámetros físico-químicos del suelo.  
- 🧠 **IA generativa (Gemini API)** para análisis contextual y recomendaciones personalizadas.  
- ☁️ **Supabase** para gestión de usuarios, cultivos y registros históricos.  
- 🌦️ **Clima local** integrado mediante OpenWeatherMap API.  
- 📜 **Historial PDF** de resultados con exportación profesional.  
- 🗺️ **Mapa interactivo** con Google Maps para localizar tiendas agrícolas.  
- 📱 **Interfaz moderna y responsiva** diseñada en Flutter.  
- 🔒 **Validación profesional**: recordatorio de revisión agronómica.  

---

## 🧩 Estructura del Proyecto
```
lib/
├── models/                    # Modelos de datos
│   ├── clima.dart
│   ├── cultivo.dart
│   ├── parametro.dart
│   ├── suelo.dart
│   └── usuario_contexto.dart
│
├── screens/                   # Interfaces gráficas (UI)
│   ├── analisis/
│   │   └── interpretacion_general_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── clima/
│   │   └── ClimaScreen.dart
│   ├── cultivo/
│   │   ├── hectareas_screen.dart
│   │   └── select_cultivo_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── maps/
│   │   └── maps_screen.dart
│   ├── pdf/
│   │   └── historial_screen.dart
│   └── suelo/
│       ├── parametros_suelo_screen.dart
│       └── select_tipo_suelo_screen.dart
│
├── services/                  # Lógica de negocio y APIs
│   ├── auth_service.dart
│   ├── clima_service.dart
│   ├── cultivo_service.dart
│   ├── cultivo_area_service.dart
│   ├── ia_service.dart        # Comunicación con Gemini API
│   ├── parametro_service.dart
│   ├── suelo_service.dart
│   ├── historial_service.dart
│   └── usuario_contexto_service.dart
│
└── main.dart                  # Punto de entrada principal
```

---

## 🧱 Arquitectura de Software

- **Frontend móvil:** Flutter (Dart)
- **Backend y Base de Datos:** Supabase (PostgreSQL)
- **Motor de IA:** Gemini API (Google AI)
- **Servicios externos:** 
  - OpenWeatherMap (clima)
  - Google Maps API (geolocalización y mapas)
- **Control de versiones:** GitHub
- **Generación de PDFs:** Package `pdf` de Flutter

---
## 🧭 Diagrama de Arquitectura
```
┌─────────────────────────────────────────────────────────┐
│                    USUARIO FINAL                        │
│                  (Agricultor/Agrónomo)                  │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│              APLICACIÓN MÓVIL FLUTTER                   │
│  ┌──────────┬──────────┬──────────┬──────────────────┐ │
│  │  Login/  │  Análisis│ Historial│    Mapas &       │ │
│  │ Registro │  Suelo   │   PDF    │    Clima         │ │
│  └──────────┴──────────┴──────────┴──────────────────┘ │
└──────────────────────┬──────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
┌──────────────┐ ┌──────────┐ ┌─────────────────┐
│   SUPABASE   │ │  GEMINI  │ │ OPENWEATHERMAP  │
│  (Backend)   │ │   API    │ │   & GOOGLE      │
│              │ │   (IA)   │ │     MAPS        │
│ • Auth       │ │          │ │                 │
│ • PostgreSQL │ │ • NLP    │ │ • Clima         │
│ • Storage    │ │ • Gemini │ │ • Geolocalización│
└──────────────┘ └──────────┘ └─────────────────┘
```

---

## ⚙️ Instalación y Configuración

### 🪶 1. Clonar el repositorio
```bash
git clone https://github.com/<tu_usuario>/terragem.git
cd terragem
```

### 📦 2. Instalar dependencias
```bash
flutter pub get
```

### 🔐 3. Crear archivo `.env` en la raíz del proyecto
```env
# 🌱 CONFIGURACIÓN DE TERRAGEM

# Supabase
SUPABASE_URL=https://<your_project>.supabase.co
SUPABASE_ANON_KEY=<your_supabase_anon_key>

# Google Gemini (IA generativa)
GEMINI_API_KEY=<your_gemini_api_key>

# OpenWeatherMap (pronóstico climático)
OPENWEATHER_API_KEY=<your_openweathermap_key>

# Google Maps (mapas interactivos)
GOOGLE_MAPS_API_KEY=<your_google_maps_key>
```

### ▶️ 4. Ejecutar la aplicación
```bash
flutter run
```

---

## 🧪 Metodología de Desarrollo

El desarrollo de TerraGem se realizó bajo la metodología ágil **RAD (Rapid Application Development)**:

1. **Levantamiento de requisitos:** identificación de variables del suelo y necesidades del usuario.
2. **Diseño de prototipos:** construcción iterativa de interfaces en Flutter.
3. **Integración de APIs:** conexión con Gemini, Supabase, OpenWeatherMap y Google Maps.
4. **Validación funcional:** pruebas con análisis de suelo reales.
5. **Despliegue:** ejecución en entorno emulado y almacenamiento en la nube.

---

## 📈 Resultados del Sistema

| Métrica | Valor |
|---------|-------|
| Coincidencia con especialistas agrónomos | 92% |
| Estabilidad funcional en pruebas | 94% |
| Tiempo promedio de respuesta | < 5 segundos |
| Satisfacción del usuario | Alta (evaluación interna) |

---

## 🌍 Impacto y Alineación con ODS

TerraGem contribuye al cumplimiento de los siguientes **Objetivos de Desarrollo Sostenible (ODS)**:

- 🥦 **ODS 2:** Hambre Cero
- 🪴 **ODS 12:** Producción y Consumo Responsables
- 🌳 **ODS 15:** Vida de Ecosistemas Terrestres

---

## 🚀 Mejoras Futuras

- 🔌 Implementación de **modo offline**.
- 🌾 Expansión del modelo a nuevos cultivos y tipos de suelo.
- 🔍 Integración de una **API REST** para interoperabilidad.
- 📊 Dashboards estadísticos con métricas de fertilidad.
- 🤖 Incorporación de **análisis predictivo** de rendimiento agrícola.
- 🌐 Soporte multiidioma (inglés, quechua).

---

## 📦 Dependencias Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  google_generative_ai: ^0.2.0
  http: ^1.1.0
  geolocator: ^10.0.0
  google_maps_flutter: ^2.5.0
  pdf: ^3.10.0
  open_filex: ^4.3.2
  path_provider: ^2.1.0
```


---

## 👩‍💻 Equipo de Desarrollo

- **Autora Principal:** Carolay Delgado Santiago – Desarrolladora e investigadora responsable
- **Investigador asociado:** Dayana Cerron Vilca – Investigadora 
- **Asesor Académico:** Alex Pacheco-Pumaleque
- **Entidad financiadora:** Dirección de Innovación y Transferencia Tecnológica (DITT) – UNDC

---

## 📜 Licencia

Este proyecto se distribuye bajo la **Licencia MIT**.  
**TerraGem – UNDC 2025** fue desarrollado con fines de investigación e innovación tecnológica, orientado al uso de la inteligencia artificial para una agricultura sostenible.

---

## 💡 Disclaimer Técnico

⚠️ **TerraGem** es una herramienta de apoyo para la interpretación de análisis de suelo. **No reemplaza la asesoría de un ingeniero agrónomo** ni los análisis confirmatorios en laboratorio. Se recomienda validar siempre las sugerencias generadas antes de su aplicación en campo.

---


## 🤝 Contribuciones

Las contribuciones son bienvenidas. Si deseas colaborar:

1. Haz un **fork** del proyecto
2. Crea una **rama** para tu funcionalidad (`git checkout -b feature/nueva-funcionalidad`)
3. Haz **commit** de tus cambios (`git commit -m 'Agregar nueva funcionalidad'`)
4. Haz **push** a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un **Pull Request**

---

## 📧 Contacto

- **Email:** carolaydelgadosantiago@gmail.com
- **Universidad:** [Universidad Nacional de Cañete](https://www.undc.edu.pe)
- **GitHub:** [https://github.com/carolayds/terragem_app]

---

>>>>>>> 0ead4c2315807dc76b17e407f51f6ab8ba007b2e
