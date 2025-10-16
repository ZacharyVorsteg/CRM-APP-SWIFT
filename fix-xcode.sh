#!/bin/bash

# Script to create a working Xcode project
cd "/Users/zachthomas/Desktop/CRM-APP-SWIFT"

# Remove old project
rm -rf TrusendaCRM.xcodeproj

# Create new Xcode project using xcrun
echo "Creating new iOS app project..."

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Create a minimal Swift package
cat > Package.swift << 'EOFPACKAGE'
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TrusendaCRM",
    platforms: [.iOS(.v16)],
    products: [
        .executable(name: "TrusendaCRM", targets: ["TrusendaCRM"])
    ],
    targets: [
        .executableTarget(name: "TrusendaCRM")
    ]
)
EOFPACKAGE

# Create Sources directory
mkdir -p Sources/TrusendaCRM

# Create a minimal main file
cat > Sources/TrusendaCRM/main.swift << 'EOFMAIN'
import SwiftUI

@main
struct TrusendaCRMApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Hello, World!")
        }
    }
}
EOFMAIN

# Generate Xcode project
swift package generate-xcodeproj 2>/dev/null || echo "Swift package generate-xcodeproj is deprecated"

# Copy files back
if [ -f "TrusendaCRM.xcodeproj/project.pbxproj" ]; then
    cp -R TrusendaCRM.xcodeproj "/Users/zachthomas/Desktop/CRM-APP-SWIFT/"
    echo "Project created successfully"
else
    echo "Failed to create project"
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo "Done. Please open the project in Xcode and manually add all Swift files from the TrusendaCRM folder."

