
# 🌱 TerraGem – Mobile App for Soil Analysis Interpretation

**Mobile application developed in Flutter and Artificial Intelligence (AI)** for the **automated interpretation of agricultural soil analyses**, with the purpose of supporting sustainable agronomic decision-making.

> Research project developed at the **National University of Cañete (UNDC)**, aimed at the digital transformation of the agricultural sector through the use of accessible, high-impact technologies.

---

## 🧠 Project Description

**TerraGem** is a mobile tool that allows users to **interpret soil analysis results** through a **generative artificial intelligence** model (Google Gemini).  
Based on the physicochemical values of the soil, the app generates **personalized management recommendations** according to crop type, climate, and terrain conditions.

The system integrates multiple technological services:

- **Flutter:** cross-platform development for Android and iOS.  
- **Supabase:** cloud backend for authentication and data storage.  
- **Gemini API:** artificial intelligence for semantic interpretation of soil analysis.  
- **OpenWeatherMap:** real-time weather forecast module.  
- **Google Maps API:** geographic visualization and location of agricultural stores.

---

## 🌾 Main Features

- 🔍 **Automatic interpretation** of physicochemical soil parameters.  
- 🧠 **Generative AI (Gemini API)** for contextual analysis and personalized recommendations.  
- ☁️ **Supabase** for managing users, crops, and historical records.  
- 🌦️ **Local weather** integrated via OpenWeatherMap API.  
- 📜 **PDF history** of results with professional export.  
- 🗺️ **Interactive map** with Google Maps to locate agricultural stores.  
- 📱 **Modern, responsive interface** designed in Flutter.  
- 🔒 **Professional validation**: reminder for agronomic review.  

---

## 🧩 Project Structure
```
lib/
├── models/                    # Data models
│   ├── clima.dart
│   ├── cultivo.dart
│   ├── parametro.dart
│   ├── suelo.dart
│   └── usuario_contexto.dart
│
├── screens/                   # Graphical interfaces (UI)
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
├── services/                  # Business logic and APIs
│   ├── auth_service.dart
│   ├── clima_service.dart
│   ├── cultivo_service.dart
│   ├── cultivo_area_service.dart
│   ├── ia_service.dart        # Communication with Gemini API
│   ├── parametro_service.dart
│   ├── suelo_service.dart
│   ├── historial_service.dart
│   └── usuario_contexto_service.dart
│
└── main.dart                  # Main entry point
```

---

## 🧱 Software Architecture

- **Mobile Frontend:** Flutter (Dart)
- **Backend and Database:** Supabase (PostgreSQL)
- **AI Engine:** Gemini API (Google AI)
- **External Services:** 
  - OpenWeatherMap (weather)
  - Google Maps API (geolocation and maps)
- **Version Control:** GitHub
- **PDF Generation:** Flutter `pdf` package

---
## 🧭 Architecture Diagram
```
┌─────────────────────────────────────────────────────────┐
│                      END USER                           │
│                 (Farmer / Agronomist)                   │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│              FLUTTER MOBILE APPLICATION                 │
│  ┌──────────┬──────────┬──────────┬──────────────────┐ │
│  │  Login/  │   Soil   │  PDF     │    Maps &        │ │
│  │ Register │ Analysis │ History  │    Weather       │ │
│  └──────────┴──────────┴──────────┴──────────────────┘ │
└──────────────────────┬──────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
┌──────────────┐ ┌──────────┐ ┌─────────────────┐
│   SUPABASE   │ │  GEMINI  │ │ OPENWEATHERMAP  │
│  (Backend)   │ │   API    │ │   & GOOGLE      │
│              │ │   (AI)   │ │     MAPS        │
│ • Auth       │ │          │ │                 │
│ • PostgreSQL │ │ • NLP    │ │ • Weather       │
│ • Storage    │ │ • Gemini │ │ • Geolocation   │
└──────────────┘ └──────────┘ └─────────────────┘
```

---

## ⚙️ Installation and Configuration

### 🪶 1. Clone the repository
```bash
git clone https://github.com/<your_username>/terragem.git
cd terragem
```

### 📦 2. Install dependencies
```bash
flutter pub get
```

### 🔐 3. Create a `.env` file in the project root
```env
# 🌱 TERRAGEM CONFIGURATION

# Supabase
SUPABASE_URL=https://<your_project>.supabase.co
SUPABASE_ANON_KEY=<your_supabase_anon_key>

# Google Gemini (generative AI)
GEMINI_API_KEY=<your_gemini_api_key>

# OpenWeatherMap (weather forecast)
OPENWEATHER_API_KEY=<your_openweathermap_key>

# Google Maps (interactive maps)
GOOGLE_MAPS_API_KEY=<your_google_maps_key>
```

### ▶️ 4. Run the application
```bash
flutter run
```

---

## 🧪 Development Methodology

TerraGem was developed using the **RAD (Rapid Application Development)** agile methodology:

1. **Requirements gathering:** identification of soil variables and user needs.
2. **Prototype design:** iterative construction of interfaces in Flutter.
3. **API integration:** connection with Gemini, Supabase, OpenWeatherMap, and Google Maps.
4. **Functional validation:** testing with real soil analyses.
5. **Deployment:** execution in an emulated environment with cloud storage.
---

## 🌍 Impact and Alignment with SDGs

TerraGem contributes to the fulfillment of the following **Sustainable Development Goals (SDGs)**:

- 🥦 **SDG 2:** Zero Hunger
- 🪴 **SDG 12:** Responsible Consumption and Production
- 🌳 **SDG 15:** Life on Land

---

## 🚀 Future Improvements

- 🔌 Implementation of **offline mode**.
- 🌾 Expansion of the model to new crops and soil types.
- 🔍 Integration of a **REST API** for interoperability.
- 📊 Statistical dashboards with fertility metrics.
- 🤖 Incorporation of **predictive analysis** of agricultural yield.
- 🌐 Multilingual support (Spanish, Quechua).

---

## 📦 Main Dependencies
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

## 👩‍💻 Development Team

- **Lead Author:** Carolay Delgado Santiago – Lead Developer and Researcher
- **Associate Researcher:** Dayana Cerron Vilca – Researcher
- **Academic Advisor:** Alex Pacheco-Pumaleque
- **Funding Entity:** Directorate of Innovation and Technology Transfer (DITT) – UNDC

---

## 📜 License

This project is distributed under the **MIT License**.  
**TerraGem – UNDC 2025** was developed for research and technological innovation purposes, aimed at the use of artificial intelligence for sustainable agriculture.

---

## 💡 Technical Disclaimer

⚠️ **TerraGem** is a support tool for the interpretation of soil analyses. **It does not replace the advice of an agronomic engineer** or confirmatory laboratory analyses. It is always recommended to validate the generated suggestions before applying them in the field.

---


## 🤝 Contributions

Contributions are welcome. If you wish to collaborate:

1. **Fork** the project
2. Create a **branch** for your feature (`git checkout -b feature/new-feature`)
3. **Commit** your changes (`git commit -m 'Add new feature'`)
4. **Push** to the branch (`git push origin feature/new-feature`)
5. Open a **Pull Request**

---

## 📧 Contact

- **Email:** carolaydelgadosantiago@gmail.com
- **University:** [National University of Cañete](https://www.undc.edu.pe)
- **GitHub:** [https://github.com/carolayds/terragem_app]

---

