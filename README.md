# 💳 Flutter Credit Card Scanner

**Developed by: Muhammad Usman**

A high-performance, real-time Credit Card Scanner application built using **Flutter** and **Google ML Kit**. This app solves common camera lag issues, uses custom logic to filter card numbers accurately, and features a premium, banking-standard UI.



## 🚀 Key Features

- **⚡ Real-time OCR:** Instant text recognition using Google ML Kit (On-Device).
- **🧠 Smart Filtering:** Implements "Fast Scan" logic to ignore noise and detect 13-19 digit card numbers starting with valid prefixes (3, 4, 5, 6).
- **🏎️ Performance Optimized:** Optimized `ImageByte` conversion pipeline to prevent camera lag and ensure 60 FPS scanning.
- **🎨 Modern UI:** Features a **Dark Mode** design with a **Neon Scanner Overlay**, **Glassmorphism** controls, and smooth laser animations.
- **📳 Haptic Feedback:** Provides vibration feedback upon successful detection and auto-navigation.
- **🔦 Flashlight Support:** Built-in toggle for low-light scanning environments.

## 🛠 Plugins Used

This project relies on the following key Flutter plugins:

- [camera](https://pub.dev/packages/camera): For accessing the device camera stream.
- [google_mlkit_text_recognition](https://pub.dev/packages/google_mlkit_text_recognition): For optical character recognition (OCR).
- [permission_handler](https://pub.dev/packages/permission_handler): For handling runtime camera permissions.
- [vibration](https://pub.dev/packages/vibration): For haptic feedback on detection.
- [google_fonts](https://pub.dev/packages/google_fonts): For `Orbitron` (Tech) and `Montserrat` (Modern) typography.

## ⚙️ Installation & Setup

1.  **Clone the repository:**

    ```bash
    git clone [https://github.com/usman-codes-01/card_scanner.git](https://github.com/usman-codes-01/card_scanner.git)
    cd card_scanner
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Platform Configuration:**

    ### iOS (Info.plist)
    Add the camera usage description:
    ```xml
    <key>NSCameraUsageDescription</key>
    <string>This app needs camera access to scan credit cards.</string>
    ```

    ### Android (build.gradle)
    Ensure your `android/app/build.gradle` defines a minimum SDK version compatible with ML Kit:
    ```gradle
    minSdkVersion 21
    ```

4.  **Run the app:**

    ```bash
    flutter run
    ```

## 📱 Use Cases

- **E-commerce Apps:** Seamless checkout experience without manual entry.
- **Fintech Applications:** Quick card onboarding and verification.
- **Digital Wallets:** Fast payment method additions.

## 👨‍💻 Author

**Muhammad Usman**

- 🔗 **LinkedIn:** [Connect with me](https://www.linkedin.com/in/muhammad-usman-81994a324)


---
*© 2026 Muhammad Usman. All Rights Reserved.*