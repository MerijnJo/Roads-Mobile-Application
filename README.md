# Roads

> **A smart mobile application for discovering and experiencing unique driving routes.**

##  About

**Roads** is a mobile application built with **Flutter** that allows users to find driving routes in both well-known and hidden locations. The app focuses on the discovery of scenic or interesting paths rather than just the fastest commute.

When exploring potential journeys, the app highlights points of interest (POIs) along various paths, such as scenic viewpoints or notable landmarks, helping users choose their ideal experience. Users can craft custom itineraries by adding POIs to a selected route and export the final journey directly to external navigation apps like Google Maps or Apple Maps. Furthermore, the platform features an **AI system** that analyzes user preferences and saved trips to provide highly tailored route recommendations.

##  Project Goals

The objective is to combine route discovery, scenic experiences, and personal recommendations into a single platform. The focus lies not on functional A-to-B navigation, but on making the driving experience smarter, more exploratory, and highly personalized through the use of data and AI.

##  Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Frontend Framework** | Flutter (Dart) |
| **State Management** | Riverpod |
| **Routing** | go_router |
| **Maps & Geospatial** | flutter_map, OpenStreetMap (OSM), GeoJSON |
| **Backend & Database** | Supabase (PostgreSQL / PostGIS), Auth, Storage |
| **AI & Telemetry** | Python, FastAPI, Scikit-learn / TensorFlow |
| **Architecture** | Feature-first, Repository Pattern |
| **CI/CD** | GitHub Actions / Codemagic |

##  Key Features

  * **Route Discovery:** Find interesting routes that prioritize the experience over the destination.
  * **Interactive POIs:** Discover extra info about viewpoints and landmarks while planning your journey.
  * **Route Builder & Export:** Craft your perfect trip by adding discovered POIs to a route and instantly export it to Apple Maps or Google Maps for seamless turn-by-turn navigation.
  * **AI Personalization:** Receive smart route advice based on your exploration habits and preferred route styles.
  * **Smart Exploration:** Seamless integration of route discovery with data-driven insights, focusing on the journey rather than the destination.

##  Getting Started

### 1\. Prerequisites

To run this project locally, ensure you have:

  * [Flutter SDK](https://www.google.com/search?q=https://docs.flutter.dev/get-started/install)
  * [Dart SDK](https://www.google.com/search?q=https://dart.dev/get-started/sdk)
  * An Android Emulator, iOS Simulator, or physical device.

### 2\. Installation & Launch

```bash
# Clone the repository
git clone https://github.com/[your-username]/roads.git
cd roads

# Install dependencies
flutter pub get

# Run the app
flutter run
```

For Supabase-backed development, create a private local runner:

```powershell
Copy-Item scripts/run_dev.example.ps1 scripts/run_dev.ps1
```

Edit `scripts/run_dev.ps1` with your Supabase URL and publishable key, then run:

```powershell
.\scripts\run_dev.ps1
```

##  Architecture & Standards

  * **Feature-First Structure:** Code is organized by feature (e.g., `map`, `discover`, `profile`) for maximum scalability and maintainability.
  * **Separation of Concerns:** Strict decoupling of UI (Widgets/Screens) from business logic (Repositories/Providers).
  * **Geospatial Queries:** Utilizing PostGIS via Supabase for lightning-fast location-based route fetching.
  * **Secure Environments:** Using `.env` injection to keep API keys and secrets secure.

##  Roadmap

  - [x] Project initialization & Feature-first architecture setup
  - [ ] State Management (Riverpod) & Routing (go_router) integration
  - [ ] Backend setup with Supabase (Auth & PostgreSQL)
  - [ ] Map rendering & GeoJSON parsing with flutter_map
  - [ ] Interactive route exploration & POI discovery
  - [ ] Route builder & third-party navigation export (Google Maps/Apple Maps)
  - [ ] AI Recommendation microservice creation (Python/FastAPI)
