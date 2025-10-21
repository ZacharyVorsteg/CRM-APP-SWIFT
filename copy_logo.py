#!/usr/bin/env python3
import shutil
import os

source = "/Users/zachthomas/Desktop/CRM APP/public/trusenda-logo.png"
dest = "/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Resources/Assets.xcassets/TrusendaLogo.imageset/trusenda-logo.png"

if os.path.exists(source):
    shutil.copy2(source, dest)
    print("✅ Logo copied successfully!")
    print(f"   Size: {os.path.getsize(dest)} bytes")
    print("")
    print("🎨 Your login screen now has:")
    print("   ✅ Trusenda logo with rounded corners")
    print("   ✅ 'COMMERCIAL & INDUSTRIAL REAL ESTATE CRM' tagline")
    print("   ✅ 'Built by Realtors, for Realtors'")
    print("")
    print("Rebuild in Xcode (Cmd+B) to see it!")
else:
    print(f"❌ Source not found: {source}")

