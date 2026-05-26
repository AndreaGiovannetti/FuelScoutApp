# ⛽ FuelScout — Flutter App

> **Il carburante più conveniente, sempre a portata di mano.**
> Real-time fuel prices • Interactive map • Smart savings • Gorgeous dark UI

---

## 📱 Features

| Feature | Description |
|---|---|
| 🗺️ **Interactive Map** | flutter_map (OpenStreetMap / CartoDB dark tiles) with live price markers |
| 🔍 **City Search** | Instant autocomplete over 30+ Italian cities with recent history |
| ⛽ **Multi-Fuel** | Benzina 95/98, Gasolio, Gasolio+, GPL, Elettrico, Idrogeno |
| 💰 **Savings Engine** | Compares each station vs zone average — shows % saved |
| 🏆 **Best Price Badge** | Cheapest station highlighted on map + list |
| 📌 **Favourites** | Bookmark stations, persisted via SharedPreferences |
| 🎛️ **Filters** | Self-service only, open only, radius slider (1–20 km), sort |
| 📍 **GPS Location** | One-tap locate + auto-reload stations |
| 💾 **Map Persistence** | Saves last center/zoom/city across app restarts |
| 🌙 **Dark UI** | Fuel-tech aesthetic: deep navy + amber glow + cyan accents |
| 🚀 **Onboarding** | 3-step animated intro with location permission request |
| ⚙️ **Settings** | Default fuel, radius, unit (km/mi), price alerts, recent cities |

---

## 🏗️ Architecture

```
lib/
├── main.dart                    # Entry point, providers, system chrome
├── theme/
│   └── app_theme.dart           # Full palette, typography, gradients, shadows
├── models/
│   └── station.dart             # Station, FuelPrice, FuelType, StationBrand
├── providers/
│   ├── stations_provider.dart   # Stations state, filters, sorting, favourites
│   └── preferences_provider.dart# SharedPreferences-backed user settings
├── services/
│   ├── fuel_data_service.dart   # Mock data generator + city search + analytics
│   └── location_service.dart    # Geolocator wrapper
├── screens/
│   ├── onboarding_screen.dart   # 3-page animated intro
│   ├── main_shell.dart          # PageView + animated bottom nav + search FAB
│   ├── home_screen.dart         # Dashboard: hero price, stats, top cheap, avgs
│   ├── map_screen.dart          # flutter_map + markers + filter bar + panel
│   ├── search_screen.dart       # City search with highlight + recents
│   ├── station_detail_screen.dart # Full station view with prices, amenities
│   └── settings_screen.dart    # All preferences with live controls
└── widgets/
    └── station_card.dart        # StationCard, FuelTypeChip, PriceTag, SavingsCard
```

**State management:** Provider (ChangeNotifier)
**Persistence:** SharedPreferences (preferences + map state + favourites + recent cities)
**Data:** Mock generator (plug in real API by replacing `FuelDataService.generateStationsNear`)

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.10+ (`flutter --version`)
- Dart 3.0+
- Android Studio / Xcode for device/emulator

### Run

```bash
cd fuelscout
flutter pub get
flutter run
```

### Build release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `provider` | State management |
| `flutter_map` | Interactive OpenStreetMap map |
| `latlong2` | Lat/lng coordinate types |
| `geolocator` | GPS location |
| `geocoding` | Reverse geocoding |
| `shared_preferences` | Persistent storage |
| `http` / `dio` | HTTP client (ready for real API) |
| `google_fonts` | DM Sans body font |
| `shimmer` | Loading skeleton |
| `animations` | Material transitions |

---

## 🔌 Connecting a Real API

Replace the mock generator in `lib/services/fuel_data_service.dart`:

```dart
// Replace generateStationsNear() with a real HTTP call, e.g.:
static Future<List<Station>> fetchFromApi(LatLng center) async {
  final resp = await Dio().get(
    'https://api.yourfuelservice.com/v1/stations',
    queryParameters: {
      'lat': center.latitude,
      'lng': center.longitude,
      'radius': 10, // km
    },
  );
  return (resp.data['stations'] as List)
      .map((j) => Station.fromJson(j))
      .toList();
}
```

Suggested free/open APIs:
- **Ministero dello Sviluppo Economico** (Italy) — official open data
- **Open Fuel Price API** — European coverage
- **PriceSpy API** — community-sourced prices

---

## 🎨 Design System

| Token | Value |
|---|---|
| Background | `#0B0D12` |
| Surface | `#13161F` |
| Accent Amber | `#FF6B00` |
| Accent Cyan | `#00D4FF` |
| Success Green | `#00E676` |
| Font Display | Syne (800 weight) |
| Font Body | DM Sans |

---

## 📄 License

MIT — free for personal and commercial use.

---

*Built with Flutter 3 · Provider · flutter_map · Syne + DM Sans*
