# ArtisanArc - Your Personal Craft Toolkit

**ArtisanArc** is now a fully self-contained, offline-first craft supply organizer and personal toolkit. Designed for makers, artists, and independent crafters, it combines comprehensive inventory tracking, intuitive project planning, visual documentation, compliance management, and sales logging — all wrapped in an elegant and user-friendly interface. Every feature is available for your personal use, with no limitations or paywalls.

---

## Features

ArtisanArc provides a complete suite of tools to manage your craft projects and supplies:

-   **Inventory Manager** – Effortlessly add and categorize materials (yarn, fabric, paper), assign pricing, and track storage locations. Keep a detailed record of all your craft supplies.
-   **QR Integration** – Generate and scan QR codes for quick identification of items and streamlined reordering processes.
-   **Visual Documentation** – Enhance your records by attaching photos, extracting color palettes, and managing visual swatches for your materials and projects.
-   **Craft Timeline Projects** – Plan and track your craft projects with detailed timelines, milestones, and linked material requirements.
-   **Compliance Tracker** – Easily mark and manage safety certifications (e.g., UKCA, US equivalents) relevant to your craft products.
-   **Smart Shopping** – Create and manage shopping lists, track preferred vendors, and keep an eye on costs for your supplies.
-   **Multilingual Support** – The app supports both UK and US English, ensuring a comfortable experience for a wider audience.
-   **Offline AI Hints** – Access craft-specific AI-powered suggestions and tips, fully available offline to assist you anytime, anywhere.
-   **Daily Sales Tracker** – Log your sales efficiently by day, with direct links to your inventory for accurate stock management.
-   **Revenue Summary** – Gain insights into your craft business with monthly revenue views and the ability to export detailed CSV/PDF reports.
-   **Label Templates** – Create and print customizable labels for organizing your supplies or for product packaging.
-   **Event Planning Tools** – Organize your craft-related events and sync them with your calendar for seamless management.
-   **Authentication** – Secure your personal data with biometric login options and an app passcode.

---

## Getting Started

### Requirements
-   Flutter 3.10+
-   Dart SDK 3.1+
-   Android Studio or VSCode (for development environment)

ArtisanArc is designed to be a personal, offline-first application, ensuring your data remains private and accessible without an internet connection.

---

## Build Runner Script

A convenient build runner script (`runner.sh`) is provided to automate common development and build tasks. You can use it to clean the project, fetch dependencies, run code generation, execute tests, and build an Android APK.

### Commands:

-   `./runner.sh clean` – Clean Flutter build artifacts.
-   `./runner.sh get` – Fetch all Flutter dependencies.
-   `./runner.sh generate` – Run `build_runner` for code generation (Hive, JSON, etc.).
-   `./runner.sh test` – Run all tests in the project.
-   `./runner.sh build-apk` – Build the release version of the Android APK.
-   `./runner.sh all` – Run the full build sequence: clean, get, generate, and build-apk.

Make sure to give the script execution permissions before running: `chmod +x runner.sh`.
