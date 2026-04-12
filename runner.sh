#!/bin/bash

# ArtisanArc Build Runner Script
# This script helps automate common development and build tasks for ArtisanArc.

# Exit on any error
set -e

echo "--------------------------------------------------"
echo "ArtisanArc - Personal Edition - Build Runner"
echo "--------------------------------------------------"

# Function to display usage
usage() {
    echo "Usage: ./runner.sh [command]"
    echo ""
    echo "Commands:"
    echo "  clean       - Clean Flutter build artifacts"
    echo "  get         - Fetch Flutter dependencies"
    echo "  generate    - Run build_runner for code generation (Hive, JSON, etc.)"
    echo "  test        - Run all tests"
    echo "  build-apk   - Build Android APK"
    echo "  all         - Run clean, get, generate, and build-apk"
    echo ""
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null
then
    echo "Error: Flutter SDK is not installed or not in PATH."
    exit 1
fi

case "$1" in
    clean)
        echo "Cleaning Flutter project..."
        flutter clean
        ;;
    get)
        echo "Fetching dependencies..."
        flutter pub get
        ;;
    generate)
        echo "Running code generation..."
        flutter pub run build_runner build --delete-conflicting-outputs
        ;;
    test)
        echo "Running tests..."
        flutter test
        ;;
    build-apk)
        echo "Building Android APK..."
        flutter build apk --release
        echo "APK build complete. You can find it in build/app/outputs/flutter-apk/app-release.apk"
        ;;
    all)
        echo "Running full build sequence..."
        flutter clean
        flutter pub get
        flutter pub run build_runner build --delete-conflicting-outputs
        flutter build apk --release
        echo "Full build complete."
        ;;
    *)
        usage
        exit 1
        ;;
esac

echo "Done."
