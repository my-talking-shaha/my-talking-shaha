#!/usr/bin/env bash
set -euo pipefail

echo "Running format check..."
dart format --set-exit-if-changed .

echo "Running analyzer..."
flutter analyze

echo "Running tests..."
flutter test
