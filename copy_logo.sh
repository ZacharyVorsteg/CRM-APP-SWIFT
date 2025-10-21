#!/bin/bash

# Copy Trusenda logo to iOS app assets
echo "📋 Copying Trusenda logo to iOS app..."

SOURCE="/Users/zachthomas/Desktop/CRM APP/public/trusenda-logo.png"
DEST="/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Resources/Assets.xcassets/TrusendaLogo.imageset/trusenda-logo.png"

if [ -f "$SOURCE" ]; then
    cp "$SOURCE" "$DEST"
    echo "✅ Logo copied successfully!"
    echo "   From: $SOURCE"
    echo "   To: $DEST"
    echo ""
    echo "Now rebuild in Xcode (Cmd+B) to see your logo!"
else
    echo "❌ Source logo not found at: $SOURCE"
fi

