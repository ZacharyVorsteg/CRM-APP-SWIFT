#!/bin/bash
cd "/Users/zachthomas/Desktop/CRM-APP-SWIFT"

# Open Xcode workspace
open -a Xcode TrusendaCRM.xcworkspace

# Wait for Xcode to open
sleep 3

# Use AppleScript to autocreate schemes
osascript << 'APPLESCRIPT'
tell application "System Events"
    tell process "Xcode"
        -- Wait for Xcode to be frontmost
        set frontmost to true
        delay 1
        
        -- Click Product menu
        click menu bar item "Product" of menu bar 1
        delay 0.5
        
        -- Click Scheme submenu
        click menu item "Scheme" of menu "Product" of menu bar item "Product" of menu bar 1
        delay 0.5
        
        -- Click Autocreate Schemes Now
        try
            click menu item "Autocreate Schemes Now" of menu "Scheme" of menu item "Scheme" of menu "Product" of menu bar item "Product" of menu bar 1
            delay 1
        end try
    end tell
end tell
APPLESCRIPT

echo "✅ Schemes autocreated!"
echo "Now select TrusendaCRM scheme and build"
