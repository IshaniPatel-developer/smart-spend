# 🌌 Smart Spend — Premium AI-Powered Expense Manager

Smart Spend is a next-generation expense tracker built with **Flutter** and powered by **Google Gemini AI**. Featuring a stunning glassmorphism design system, it provides instant receipt parsing, spending pattern analysis, and secure credentials management.

## 📱 Demo Video
Watch the application in action showing the receipt scanner and insights analysis:
[Watch Demo Video](media/demo_video.mp4)

---

## ✨ Features

* **📷 AI Receipt Scanner**: Capture or upload a receipt from your camera or gallery. Gemini parses the merchant name, amount, date, and category automatically.
* **🛡️ Security-First API Keys**: Leverages the *Secrets Gradle Plugin* and *Android Platform Channels* to inject and retrieve the Google AI Studio API key at runtime. No keys are hardcoded in the Flutter source code.
* **💵 Multi-Currency Auto-Conversion**: Scanned foreign currency amounts (e.g. `$`, `€`, `£`, `S$`) are automatically converted on-the-fly to **INR (₹)** based on real-time approximation.
* **🛑 Smart Validation Overlay**: Clean, minimal full-screen loader animation during active AI processing with non-blocking inline error dismissing.
* **📊 Analytics Dashboard**: Beautiful visual charts detailing category distributions, spending limits, and AI-driven custom insights.
* **🌙 Obsidian Dark Glass Theme**: Premium dark theme featuring harmonized gradients, responsive choice chips, and calendar-only date constraints.

---

## 🏗️ Architecture & Project Structure

The project strictly follows **Clean Architecture** combined with the **BLoC (Business Logic Component)** pattern to ensure testability, scalability, and loose coupling:

```
lib/
├── core/
│   ├── constants/       # App-wide strings, theme values
│   ├── di/              # Service locator setup (get_it)
│   ├── network/         # Gemini API client, Dio config
│   ├── theme/           # Glassmorphic gradients & custom styling
│   └── utils/           # Shared validators, error handlers
└── features/
    ├── expense_management/
    │   ├── data/        # SQFlite database entities, repositories
    │   ├── domain/      # Use cases & entity definitions
    │   └── presentation/# Dashboard screens, glass card widgets, BLoCs
    ├── insights/
    │   └── ...          # Spending analysis BLoC, entities
    └── receipt_scanner/
        └── ...          # AI scanning BLoC, repositories
```

---

## 🚀 Getting Started

### 📋 Prerequisites
* **Flutter SDK**: `>=3.0.0`
* **Android Studio / VS Code** (with Flutter & Dart extensions)
* **Google AI Studio API Key**

### 🔑 Security Setup (Injecting your API Key)
To run the app securely without exposing your API Key:

1. Create a `local.properties` file in your `android/` directory (if it does not exist already).
2. Add your Google AI Studio API key:
   ```properties
   GEMINI_API_KEY=your_actual_api_key_here
   ```
3. The app's native Gradle task will load this key automatically into `BuildConfig` and deliver it dynamically via secure channels.

### 🔑 Generating a Google AI Studio API Key
If you encounter `401 Unauthorized` or authentication errors, your Gemini API key might be expired. Follow these steps to generate a new key:
1. Navigate to [Google AI Studio](https://aistudio.google.com/).
2. Sign in with your Google Account.
3. Click on the **"Get API Key"** button in the top left sidebar.
4. Click **"Create API Key"**.
5. Select a Google Cloud project (or create a new one) and click **"Create API Key in existing project"**.
6. Copy the generated key and replace the `GEMINI_API_KEY` value in your `android/local.properties` file.

### 🏃 Running the Application

To run the app on an active Android emulator or physical device:
```bash
flutter run
```

---

## 📦 Building a Release APK
To compile a highly optimized production installer with split binaries for individual CPU architectures (reducing installation size to ~16-18MB):

```bash
flutter build apk --release --split-per-abi
```

Target Output Files:
* `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (For modern physical Android devices)
* `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (For older/budget Android devices)
