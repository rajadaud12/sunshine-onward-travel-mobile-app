# ✈️ Sunshine Onward Travel Mobile App

> **Premium Flight-Connected Ride Booking** — Seamlessly book rides to and from airports with real-time tracking, flight integration, and hassle-free travel coordination.

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Features & Key Capabilities](#-features--key-capabilities)
  - [1. Flight-Integrated Ride Booking](#1-flight-integrated-ride-booking)
  - [2. Real-Time Driver Tracking](#2-real-time-driver-tracking)
  - [3. Intelligent Schedule Optimization](#3-intelligent-schedule-optimization)
  - [4. Secure Payment Integration](#4-secure-payment-integration)
  - [5. Trip History & Analytics](#5-trip-history--analytics)
- [System Architecture](#-system-architecture)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the App](#running-the-app)
  - [Building for Release](#building-for-release)
- [Development Workflow](#-development-workflow)
- [Technology Stack](#-technology-stack)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌟 Overview

**Sunshine Onward Travel** is a cross-platform Flutter mobile application engineered to revolutionize airport ground transportation. The app intelligently bridges flight schedules with ride services, ensuring passengers never miss their connection while providing drivers with optimized, predictable itineraries.

* ✈️ **Flight-Aware Booking**: Automatically synchronizes with flight schedules to propose optimal pickup/dropoff times.
* 📍 **Live GPS Tracking**: Real-time driver location streaming with ETA recalculation and route optimization.
* 💳 **Multi-Payment Methods**: Support for credit cards, digital wallets, and corporate billing accounts.
* 🎯 **Smart Matching**: AI-powered driver assignment based on proximity, ratings, vehicle type, and flight timing.
* 📊 **Comprehensive Analytics**: Trip summaries, spending insights, and travel history with exportable reports.
* 🔐 **Enterprise-Grade Security**: End-to-end encrypted communications, PCI-DSS compliance, and two-factor authentication.

---

## 🏛 Features & Key Capabilities

```
┌──────────────────────────────────────────────────────────────┐
│           Sunshine Onward Travel Mobile App                  │
│              (iOS & Android via Flutter)                     │
└─────────────┬────────────────────────────────────────────────┘
              │ Dart / Native Channels
              ▼
┌──────────────────────────────────────────────────────────────┐
│                  Core Feature Modules                        │
├──────────────┬───────────────┬───────────────┬───────────────┤
│   Flight     │   Ride        │    Payment    │    User       │
│  Integration │   Booking     │  Processing   │    Profile    │
└──────┬───────┴───────┬───────┴───────┬───────┴───────┬───────┘
       │               │               │               │
       ▼               ▼               ▼               ▼
   ┌────────┐    ┌─────────┐    ┌──────────┐    ┌──────────┐
   │ Flight │    │  Maps & │    │ Stripe / │    │ Firebase │
   │ APIs   │    │   GPS   │    │ PayPal   │    │  Auth    │
   │        │    │ Services│    │ Razorpay │    │          │
   └────────┘    └─────────┘    └──────────┘    └──────────┘
```

### 1. Flight-Integrated Ride Booking
* **Flight Synchronization**: Connects to major airline APIs (Skyscanner, Amadeus, Expedia) to pull flight details and ETAs.
* **Predictive Scheduling**: Suggests ideal pickup times based on flight duration, airport procedures, and traffic patterns.
* **Itinerary Management**: One-tap booking for round-trip rides with automatic return ride scheduling.
* **Airport Terminal Selection**: Optimizes driver assignment by terminal/gate location.

### 2. Real-Time Driver Tracking
* **Live GPS Streaming**: Millisecond-precision driver location updates via WebSocket connections.
* **ETA Recalculation**: Dynamic arrival time adjustments accounting for traffic, weather, and route changes.
* **Safe Passenger Notifications**: SMS/push alerts at key waypoints (driver arrived, 5 min away, en route to destination).
* **Ride Share Optimization**: Matches multiple passengers on the same route when beneficial.

### 3. Intelligent Schedule Optimization
* **Geofencing**: Automatic task triggering when passengers enter/exit airport zones.
* **Traffic-Aware Routing**: Integration with HERE Maps or Google Maps API for real-time navigation.
* **Predictive Wait Time**: Machine learning models estimate driver arrival based on historical data.
* **Multi-Stop Planning**: Supports connecting flights with intermediate stops.

### 4. Secure Payment Integration
* **Multiple Payment Gateways**: Stripe, PayPal, Razorpay, and corporate billing (invoice-based).
* **Tokenized Cards**: Secure card storage with PCI-DSS compliance; no raw data persisted locally.
* **Dynamic Pricing**: Real-time surge pricing, loyalty discounts, and corporate rate cards.
* **Fare Splitting**: Divide costs among multiple passengers with real-time settlement.

### 5. Trip History & Analytics
* **Comprehensive Trip Logs**: Access to all past bookings with receipts, driver ratings, and feedback.
* **Spending Dashboard**: Monthly/yearly expense tracking with category breakdown (business vs. personal).
* **Performance Metrics**: Average rating, on-time performance, favorite drivers, and route recommendations.
* **Exportable Reports**: PDF/CSV exports for corporate reimbursement and tax filing.

---

## 📂 Project Structure

```
sunshine-onward-travel-mobile-app/
├── android/                       # Android-specific native configuration
│   ├── app/
│   │   ├── build.gradle           # Android app build configuration
│   │   └── src/
│   │       └── main/
│   │           └── AndroidManifest.xml
│   └── build.gradle               # Project-level Gradle settings
├── ios/                           # iOS-specific native configuration
│   ├── Runner.xcodeproj           # Xcode project file
│   ├── Runner/
│   │   ├── Info.plist             # iOS app metadata
│   │   └── Assets.xcassets        # iOS app icons & assets
│   └── Podfile                    # CocoaPods dependency management
├── lib/                           # Dart source code
│   ├── main.dart                  # Application entrypoint
│   ├── screens/
│   │   ├── home_screen.dart       # Home/dashboard screen
│   │   ├── booking_screen.dart    # Flight-aware booking flow
│   │   ├── tracking_screen.dart   # Live ride tracking
│   │   ├── payment_screen.dart    # Payment processing
│   │   └── profile_screen.dart    # User profile & settings
│   ├── models/
│   │   ├── trip.dart              # Trip data model
│   │   ├── user.dart              # User profile model
│   │   ├── flight.dart            # Flight information model
│   │   └── payment.dart           # Payment method model
│   ├── services/
│   │   ├── flight_service.dart    # Flight API integration
│   │   ├── booking_service.dart   # Ride booking logic
│   │   ├── payment_service.dart   # Payment processing
│   │   ├── location_service.dart  # GPS & geofencing
│   │   └── auth_service.dart      # Authentication (Firebase)
│   ├── widgets/
│   │   ├── trip_card.dart         # Reusable trip card widget
│   │   ├── driver_card.dart       # Driver profile display
│   │   └── map_widget.dart        # Map integration widget
│   ├── utils/
│   │   ├── constants.dart         # App-wide constants
│   │   ├── validators.dart        # Input validation helpers
│   │   └── theme.dart             # UI theme configuration
│   └── providers/                 # State management (Provider/Riverpod)
├── test/                          # Unit & widget tests
│   ├── unit/
│   │   └── services_test.dart
│   └── widget/
│       └── booking_screen_test.dart
├── pubspec.yaml                   # Flutter dependencies & metadata
├── .env.example                   # Environment variables template
├── .gitignore                     # Git ignore rules
├── .github/
│   └── workflows/
│       ├── android_build.yml      # Android CI/CD
│       └── ios_build.yml          # iOS CI/CD
└── README.md                      # This file
```

---

## 🛠 Getting Started

### Prerequisites
* **Flutter SDK**: Version 3.13+ ([Install Flutter](https://flutter.dev/docs/get-started/install))
* **Dart SDK**: Included with Flutter
* **Android Studio** or **Xcode**: For emulator and native development
* **API Keys**: 
  - Flight API (Skyscanner, Amadeus, or Expedia)
  - Maps API (Google Maps or HERE Maps)
  - Payment Gateway (Stripe, PayPal, or Razorpay)
  - Firebase Project for authentication

### Installation

1. **Clone the Repository**:
```bash
git clone https://github.com/rajadaud12/sunshine-onward-travel-mobile-app.git
cd sunshine-onward-travel-mobile-app
```

2. **Install Dependencies**:
```bash
flutter pub get
```

3. **Configure Environment Variables**:
```bash
cp .env.example .env
```

Edit `.env` with your API credentials:
```ini
# Flight APIs
FLIGHT_API_KEY=your_flight_api_key
FLIGHT_API_ENDPOINT=https://api.example.com/flights

# Maps & Location
MAPS_API_KEY=your_google_maps_api_key
LOCATION_TRACKING_INTERVAL=5000

# Payment Processing
STRIPE_PUBLISHABLE_KEY=pk_live_xxxxx
STRIPE_SECRET_KEY=sk_live_xxxxx
RAZORPAY_KEY_ID=key_xxxxx

# Firebase Configuration
FIREBASE_PROJECT_ID=your-firebase-project
FIREBASE_API_KEY=AIzaXxxxxx
```

### Running the App

**Development Mode (Hot Reload)**:
```bash
flutter run
```

**Run on Specific Device**:
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

**Run on iOS Simulator**:
```bash
open -a Simulator
flutter run -d iPhone
```

**Run on Android Emulator**:
```bash
flutter emulators --launch Pixel_4_API_30
flutter run
```

### Building for Release

**Android APK**:
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle** (for Google Play):
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS IPA** (for App Store):
```bash
flutter build ios --release
# Follow Xcode archival & distribution steps
```

---

## 🔄 Development Workflow

### Code Quality & Testing

Run unit and widget tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

Analyze code for issues:
```bash
flutter analyze
```

Format code:
```bash
dart format lib/ test/
```

### State Management
This project uses **Provider** or **Riverpod** for efficient state management:
- Trip booking state
- User authentication state
- Real-time location updates
- Payment transaction status

### Version Management
Versioning follows semantic versioning in `pubspec.yaml`:
```yaml
version: 1.0.0+1
```
Format: `major.minor.patch+build_number`

---

## 🛠 Technology Stack

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.13+ | Cross-platform mobile development |
| **Language** | Dart | Mobile app logic |
| **State Management** | Provider / Riverpod | App state handling |
| **Database** | SQLite / Firebase Firestore | Local & cloud data storage |
| **Authentication** | Firebase Auth | User login & security |
| **Maps & Location** | Google Maps SDK | Route planning & GPS tracking |
| **Payment** | Stripe SDK | Card payments & billing |
| **APIs** | HTTP (Dio) | Backend & third-party integrations |
| **Real-time** | Firebase Realtime DB / WebSocket | Live driver tracking |
| **CI/CD** | GitHub Actions | Automated testing & builds |

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/your-feature`)
3. **Commit** changes with clear messages (`git commit -m 'Add feature: ...'`)
4. **Push** to your fork (`git push origin feature/your-feature`)
5. **Open** a pull request with a detailed description

### Coding Standards
- Follow [Dart effective practices](https://dart.dev/guides/language/effective-dart)
- Use meaningful variable/function names
- Add comments for complex logic
- Write unit tests for new features

---

## 📄 License

This project is licensed under the **MIT License** — see the `LICENSE` file for details.

---

**Made with ❤️ for seamless airport ground transportation**
