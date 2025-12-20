# FinGuard AI — Personal Financial Digital Twin & Intelligent Decision Support

<p align="center">
  <img src="assets/icon/app_icon.png" width="120" alt="FinGuard AI Logo"/>
</p>

<p align="center">
  <b>A Secure Personal Financial Digital Twin and Intelligent Decision Support Mobile Application</b><br/>
  BSc (Hons) in Computer Science
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.32-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.8-blue?logo=dart" />
  <img src="https://img.shields.io/badge/Platform-Android-green?logo=android" />
  <img src="https://img.shields.io/badge/AI-Claude%20Sonnet-purple" />
  <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
</p>

---

## Overview

**FinGuard AI** is an AI-powered personal finance management mobile application built with Flutter. It introduces the concept of a **Personal Financial Digital Twin** — a real-time virtual model of the user's financial life that simulates future scenarios, detects spending anomalies, and delivers intelligent, context-aware financial guidance through a conversational AI assistant powered by Claude claude-sonnet-4-6.

The app operates fully offline-first using local encrypted storage, with biometric authentication to keep sensitive financial data secure.

---

## Features

### Core Finance Management
- **Dashboard** — Real-time income/expense overview with balance summary and spending ring chart
- **Transactions** — Full CRUD with 12 expense and 10 income categories, search, and filters
- **Reports** — Monthly trend charts (pie + bar) powered by fl_chart
- **Savings Goals** — Set, track, and complete financial goals with animated progress indicators

### AI & Intelligence
- **AI Financial Assistant** — Conversational chat interface powered by Claude claude-sonnet-4-6 with context-aware advice based on your actual spending data
- **AI Insights** — Auto-generated monthly spending summaries and recommendations
- **Voice Input** — Ask the AI assistant questions using your voice via speech-to-text

### Financial Digital Twin
- **What-If Simulator** — Adjust salary, savings rate, and spending to project future financial outcomes
- **Scenario Engine** — Compare multiple financial paths with visual projections

### Security & Fraud Detection
- **Biometric Authentication** — Fingerprint and face unlock via `local_auth`
- **Secure Storage** — Sessions and API keys encrypted using `flutter_secure_storage`
- **Fraud Detection** — Transaction anomaly alerts with risk scoring based on spending patterns

### Personalisation
- **Dark / Light Mode** — System-synced theme with manual toggle
- **Multi-Currency** — 130+ countries with auto currency symbol update throughout the app
- **Balance Privacy** — Balance hidden by default; tap to reveal

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.32 / Dart 3.8 |
| State Management | Provider (ChangeNotifier) |
| Local Storage | Hive (encrypted offline database) |
| Secure Storage | flutter_secure_storage |
| AI Engine | Anthropic Claude claude-sonnet-4-6 API |
| Voice Input | speech_to_text |
| Charts | fl_chart |
| Authentication | local_auth (biometrics) |
| Fonts & Icons | Google Fonts, Font Awesome Flutter |

---

## Architecture

```
lib/
├── core/
│   ├── constants/       # App-wide enums, keys, category definitions
│   ├── providers/       # SettingsProvider, ThemeProvider
│   ├── services/        # AuthService, LocalDb, ClaudeService, FirestoreService
│   ├── theme/           # AppTheme, colour palette, typography
│   ├── utils/           # Formatters (currency, date, compact)
│   └── widgets/         # MainShell (bottom nav)
│
├── features/
│   ├── auth/            # Login, Register, AuthProvider
│   ├── dashboard/       # Home screen with overview cards
│   ├── transactions/    # List, Add/Edit sheet, TransactionProvider
│   ├── goals/           # Goals screen, GoalModel, GoalProvider
│   ├── reports/         # Monthly chart reports
│   ├── health/          # Financial health score screen
│   ├── ai_assistant/    # Chat screen, AiAssistantProvider
│   ├── digital_twin/    # Simulator screen, DigitalTwinProvider
│   ├── fraud/           # Anomaly detection screen
│   ├── profile/         # Settings, country picker, API key
│   └── onboarding/      # First-launch walkthrough
│
└── main.dart            # Entry point, MultiProvider, Hive init
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.8.1`
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 21+)
- Claude API key from [console.anthropic.com](https://console.anthropic.com)

### Installation

```bash
# Clone the repository
git clone https://github.com/Punujalokith/finguard-ai.git
cd finguard-ai

# Install dependencies
flutter pub get

# Run on connected Android device
flutter run
```

### API Key Setup

1. Open the app and log in or continue as guest
2. Go to **Profile → AI Settings**
3. Enter your Claude API key
4. The key is stored locally in encrypted secure storage — it never leaves your device

---

## Security

- All financial data is stored **locally on-device** using Hive
- Sessions and API keys are encrypted via `flutter_secure_storage`
- Biometric lock (fingerprint / face) gates access to the app
- No financial data is sent to any server — AI queries contain only anonymised summaries

---

## Project Info

| | |
|---|---|
| **Degree** | BSc (Hons) in Computer Science |
| **Platform** | Android |
| **Developer** | Punujalokith |
| **Development Period** | August 2025 – December 2025 |

---

## License

This project is developed as an academic Final Year Project.  
© 2025 Punujalokith. All rights reserved.
