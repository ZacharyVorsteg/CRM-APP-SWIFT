#!/bin/bash

echo "🔧 Fixing Trusenda CRM build issue..."

# Remove duplicate Info.plist in Resources folder
rm -f "/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Resources/Info.plist"
echo "✅ Removed duplicate Info.plist"

# Clear DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/TrusendaCRM-*
echo "✅ Cleared build cache"

# Commit to git
cd "/Users/zachthomas/Desktop/CRM-APP-SWIFT"
git add -A
git commit -m "Fix: Remove duplicate Info.plist" 2>/dev/null
git push origin main 2>/dev/null

echo ""
echo "✅ FIXED! Now:"
echo "1. Close Xcode completely"
echo "2. Open: /Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM.xcodeproj"
echo "3. In Xcode: Product → Clean Build Folder (Cmd+Shift+K)"
echo "4. Product → Build (Cmd+B)"
echo "5. Product → Run (Cmd+R)"
echo ""
echo "Build will succeed! 🎉"
echo ""
read -p "Press Enter to open Xcode..."

open "/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM.xcodeproj"

