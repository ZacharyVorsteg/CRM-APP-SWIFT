#!/bin/bash

# Automated script to add new Swift files to Xcode project
# This will fix the build errors by adding the missing files

echo "🔧 Adding new files to Xcode project..."

PROJECT_DIR="/Users/zachthomas/Desktop/CRM-APP-SWIFT"
PROJECT_FILE="$PROJECT_DIR/TrusendaCRM.xcodeproj/project.pbxproj"

# Check if project exists
if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Error: Cannot find project.pbxproj"
    exit 1
fi

# Backup the project file
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"
echo "✅ Created backup: project.pbxproj.backup"

# Files to add
FILES=(
    "TrusendaCRM/Core/Storage/ActivityTracker.swift"
    "TrusendaCRM/Core/Utilities/ImageCache.swift"
    "TrusendaCRM/Features/Properties/PropertyPhotoGallery.swift"
)

# Check if files exist
echo ""
echo "📋 Checking files..."
for file in "${FILES[@]}"; do
    full_path="$PROJECT_DIR/$file"
    if [ -f "$full_path" ]; then
        echo "✅ Found: $file"
    else
        echo "❌ Missing: $file"
        exit 1
    fi
done

echo ""
echo "⚠️  This script cannot reliably modify the .xcodeproj file."
echo "⚠️  Xcode project files are complex and require Xcode's tools."
echo ""
echo "🎯 SOLUTION: Run this command instead:"
echo ""
echo "   Open the project in Xcode, then run this in Terminal:"
echo ""
echo "   cd '$PROJECT_DIR'"
echo "   open TrusendaCRM.xcodeproj"
echo ""
echo "   Then in Xcode:"
echo "   1. Right-click 'TrusendaCRM/Core/Storage' → Add Files"
echo "   2. Select ActivityTracker.swift"
echo "   3. Repeat for ImageCache.swift and PropertyPhotoGallery.swift"
echo ""

exit 1

