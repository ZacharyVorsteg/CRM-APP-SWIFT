#!/usr/bin/env python3
import os
import shutil

# Delete duplicate Info.plist
duplicate_plist = "/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Resources/Info.plist"

if os.path.exists(duplicate_plist):
    os.remove(duplicate_plist)
    print("✅ Removed duplicate Info.plist from Resources folder")
else:
    print("✅ Duplicate already removed")

# Verify only one Info.plist remains
remaining = []
for root, dirs, files in os.walk("/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM"):
    for f in files:
        if f == "Info.plist":
            remaining.append(os.path.join(root, f))

print(f"\n✅ Info.plist files found: {len(remaining)}")
for r in remaining:
    print(f"  - {r}")

if len(remaining) == 1:
    print("\n✅ PERFECT! Only one Info.plist exists")
    print("✅ Desktop project is ready to build!")
else:
    print("\n⚠️ Multiple Info.plist files found - need manual cleanup")

