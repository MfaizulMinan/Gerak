# GERAK 🏃‍♂️💪

**GERAK** adalah aplikasi fitness, pelacakan latihan (workout tracking), dan asisten kesehatan interaktif berbasis AI yang dibangun menggunakan **Flutter** dan **Firebase**. Aplikasi ini dirancang untuk membantu pengguna merencanakan latihan, memantau kemajuan aktivitas fisik secara visual, dan berkonsultasi seputar kesehatan serta kebugaran melalui AI Chatbot yang terintegrasi dengan Google Gemini.

---

## 🌟 Fitur Utama

- **🔑 Autentikasi Pengguna**: Login mudah dan aman menggunakan Firebase Authentication dan Google Sign-In.
- **Onboarding & Setup Profil**: Pengalaman pertama pengguna yang intuitif dengan panduan profil kustomisasi (target berat badan, tinggi badan, tingkat kebugaran).
- **📋 Rencana Latihan (Workout Programs)**: Pilihan program latihan harian dan mingguan yang dipersonalisasi.
- **📊 Pelacakan Kemajuan (Progress Tracking)**: Grafik statistik latihan dan kalori yang interaktif menggunakan `fl_chart`.
- **🤖 Asisten AI Chatbot**: Konsultasi kesehatan, nutrisi, dan tips olahraga kapan saja dengan chatbot pintar yang didukung oleh Google Gemini (`google_generative_ai`).
- **✨ UI Premium & Animasi**: Tampilan modern dengan transisi halus, animasi interaktif menggunakan `Lottie`, dan selebrasi keberhasilan dengan `Confetti`.

---

## 🛠️ Tech Stack & Dependensi

Aplikasi ini dibangun menggunakan teknologi terkini di ekosistem Flutter:

- **Core**: Flutter SDK (Dart)
- **Database & Auth**: Firebase Auth, Cloud Firestore, Firebase Core
- **AI Integration**: Google Generative AI SDK (Gemini API)
- **Charts & Data Visualization**: `fl_chart`
- **UI & Animations**: `lottie`, `confetti`, `cupertino_icons`
- **Sign-In Provider**: `google_sign_in`, `google_sign_in_web`

---

## 🚀 Langkah Instalasi & Menjalankan Project

Ikuti langkah-langkah di bawah ini untuk menjalankan project GERAK di mesin lokal Anda:

### 1. Prasyarat
Pastikan Anda sudah menginstal:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.11.0 atau lebih baru disarankan)
- [Dart SDK](https://dart.dev/get-started/sdk)
- Android Studio / VS Code dengan plugin Flutter terinstal
- Akun Firebase dan Project Google Cloud (untuk Gemini API)

### 2. Clone Repository
```bash
git clone https://github.com/MfaizulMinan/Gerak.git
cd gerak
```

### 3. Mengunduh Dependensi
Jalankan perintah berikut pada terminal untuk mengunduh semua package yang dibutuhkan:
```bash
flutter pub get
```

### 4. Konfigurasi Firebase
Aplikasi ini membutuhkan konfigurasi Firebase agar fitur Auth dan Firestore dapat berjalan:
1. Jalankan perintah `flutterfire configure` menggunakan FlutterFire CLI untuk mengaitkan aplikasi ke project Firebase Anda.
2. Pastikan file `lib/firebase_options.dart` tergenerasi dengan benar.
3. Aktifkan layanan **Authentication (Email & Google Sign-In)** dan **Cloud Firestore** di konsol Firebase Anda.

### 5. Konfigurasi Google Gemini API
Untuk menggunakan fitur chatbot AI:
1. Dapatkan API Key dari [Google AI Studio](https://aistudio.google.com/).
2. Konfigurasikan API Key tersebut pada kode atau environment variables aplikasi Anda agar instance `google_generative_ai` dapat berkomunikasi dengan model Gemini.

### 6. Menjalankan Aplikasi
Jalankan aplikasi menggunakan emulator Android/iOS atau perangkat fisik yang terhubung:
```bash
flutter run
```

---

## 📁 Struktur Direktori Project

```text
lib/
├── core/             # Konfigurasi tema, konstanta, dan utility global
├── models/           # Model data (User, Workout, Activity, dll.)
├── services/         # Layanan eksternal (Firebase Auth, Firestore, Gemini API)
└── views/            # UI Layar / Screens
    ├── auth/         # Login & Register
    ├── chatbot/      # Chatbot Asisten Kesehatan
    ├── dashboard/    # Halaman Utama / Dashboard
    ├── onboarding/   # Layaran Pengenalan Pertama
    ├── profile/      # Halaman Profil Pengguna
    ├── program/      # Daftar Program Olahraga
    ├── progress/     # Statistik & Grafik Kemajuan
    ├── splash/       # Splash Screen Awal
    └── workout/      # Halaman Latihan & Lari/Gerak
```

---

## 📄 Lisensi
Project ini dibuat untuk memenuhi tugas mata kuliah **Pemrograman Mobile** (UAS Pemrograman Mobile). Seluruh kode di dalam repositori ini diperuntukkan bagi tujuan pendidikan.

Copyright (c) 2026:

1. Shendi Bagus Prasetyo (24091397036)
2. Muhammad Faizul Minan (24091397048)
3. Angelica Immanuela Nazarina (24091397050)
