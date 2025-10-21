#!/bin/bash

echo "🗑️ Deleting ALL old Settings views..."

cd "/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Features/Settings"

# Delete old Settings files
rm -f "SettingsView.swift"
rm -f "EnhancedSettingsView.swift"
rm -f "CleanSettingsView.swift"

echo "✅ Deleted old Settings files"
echo ""
echo "Remaining files:"
ls -la

echo ""
echo "✅ ONLY MainSettingsView.swift should remain"
echo ""
echo "Now in Xcode:"
echo "1. Press Cmd+Shift+K (Clean Build Folder)"
echo "2. Press Cmd+B (Build)"
echo "3. Press Cmd+R (Run)"
echo ""
echo "The flickering will be GONE!"

read -p "Press Enter to continue..."

