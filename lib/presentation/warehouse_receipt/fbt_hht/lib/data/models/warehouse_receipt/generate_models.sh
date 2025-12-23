#!/bin/bash

# Script to generate JSON serialization code for Warehouse Receipt models

echo "Generating JSON serialization code..."

cd "$(dirname "$0")/../../.."

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

echo "Done! Generated .g.dart files for all models."

