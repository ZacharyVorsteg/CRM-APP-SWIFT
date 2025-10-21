#!/bin/bash

echo "🎨 Copying Trusenda logo to iOS app..."

# Source locations to try
SOURCES=(
    "/Users/zachthomas/Desktop/CRM APP/public/trusenda-logo.png"
    "/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Resources/Assets.xcassets/TrusendaLogo.imageset/trusenda-logo.png"
)

# Destination
DEST="/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Assets.xcassets/TrusendaLogo.imageset/trusenda-logo.png"

# Find and copy logo
for SOURCE in "${SOURCES[@]}"; do
    if [ -f "$SOURCE" ]; then
        echo "✅ Found logo at: $SOURCE"
        cp "$SOURCE" "$DEST"
        echo "✅ Copied to: $DEST"
        ls -lh "$DEST"
        echo ""
        echo "🎯 Logo is ready!"
        echo ""
        echo "Now in Xcode:"
        echo "1. Press Cmd+Shift+K (Clean)"
        echo "2. Press Cmd+B (Build)"
        echo "3. Press Cmd+R (Run)"
        echo ""
        echo "Your logo WILL appear!"
        exit 0
    fi
done

echo "❌ Logo file not found. Please manually copy:"
echo "   From: /Users/zachthomas/Desktop/CRM APP/public/trusenda-logo.png"
echo "   To: $DEST"

