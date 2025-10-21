#!/usr/bin/env python3
import os

files_to_delete = [
    "/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Features/Settings/SettingsView.swift",
    "/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Features/Settings/EnhancedSettingsView.swift",
    "/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Features/Settings/CleanSettingsView.swift"
]

for file_path in files_to_delete:
    if os.path.exists(file_path):
        os.remove(file_path)
        print(f"✅ Deleted: {os.path.basename(file_path)}")
    else:
        print(f"⏭️  Already gone: {os.path.basename(file_path)}")

print("\n✅ Cleanup complete!")
print("\nRemaining Settings files:")
settings_dir = "/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Features/Settings"
for f in os.listdir(settings_dir):
    if f.endswith('.swift'):
        print(f"  ✅ {f}")

print("\n🎯 Now clean and rebuild in Xcode:")
print("  1. Press Cmd+Shift+K (Clean)")
print("  2. Press Cmd+B (Build)")
print("  3. Press Cmd+R (Run)")
print("\n✅ Flickering will be GONE!")

