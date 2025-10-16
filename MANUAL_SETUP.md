# Manual Xcode Setup (5 Minutes)

The easiest way to get this working is to create the project manually in Xcode.

## Step-by-Step Instructions

### 1. Open Xcode

Launch Xcode from Applications or Spotlight

### 2. Create New Project

1. Click **"Create a new Xcode project"**
2. Or: File → New → Project

### 3. Choose Template

- Select **iOS** tab at the top
- Choose **App** template
- Click **Next**

### 4. Project Settings

Fill in these **EXACT** values:

```
Product Name:          TrusendaCRM
Team:                  (Select your Apple ID or leave None)
Organization Identifier: com.trusenda
Bundle Identifier:     com.trusenda.crm (auto-generated)
Interface:             SwiftUI
Language:              Swift
```

**Uncheck** these boxes:
- ❌ Include Tests
- ❌ Use Core Data
- ❌ Host in CloudKit

Click **Next**

### 5. Save Location

- Save to: **Desktop**
- Name the folder: **TrusendaCRM-Working**
- ✅ Check "Create Git repository on my Mac"
- Click **Create**

### 6. Delete Default Files

Xcode will create some default files. Delete these:

In the Project Navigator (left sidebar), select and delete:
- `ContentView.swift` (Right-click → Delete → Move to Trash)
- `TrusendaCRMApp.swift` (Right-click → Delete → Move to Trash)
- `Assets.xcassets` (Right-click → Delete → Move to Trash)

### 7. Add All Source Files

Now add all our Swift files:

1. Right-click on the **TrusendaCRM** folder (blue icon, top of the left sidebar)
2. Select **"Add Files to TrusendaCRM..."**
3. Navigate to: `/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/`
4. Select the **entire TrusendaCRM folder**
5. In the dialog, make sure:
   - ✅ **"Copy items if needed"** is CHECKED
   - ✅ **"Create groups"** is selected (not "Create folder references")
   - ✅ **"Add to targets: TrusendaCRM"** is CHECKED
6. Click **Add**

### 8. Verify Files Are Added

In the Project Navigator, you should now see:

```
▼ TrusendaCRM
  ▼ TrusendaCRM (folder)
    ▸ Core
      ▸ Models
      ▸ Network
      ▸ Storage
      ▸ Utilities
    ▸ Features
      ▸ Authentication
      ▸ Leads
      ▸ FollowUps
      ▸ Settings
    ▸ Resources
    TrusendaCRMApp.swift
```

**All folders should have BLUE icons** (groups), not yellow (references).

### 9. Build Settings (Optional but Recommended)

1. Click on the **TrusendaCRM project** (blue icon at top)
2. Select **TrusendaCRM target** (under TARGETS)
3. Go to **"Signing & Capabilities"** tab
4. Under **"Signing"**, select your **Team** (your Apple ID)
5. Go to **"Build Settings"** tab
6. Search for "deployment"
7. Set **iOS Deployment Target** to **16.0**

### 10. Build & Run! 🚀

1. Select a simulator from the dropdown at the top:
   - iPhone 16 Pro
   - Or any iOS 16+ device

2. Press **⌘ + R** (or click the Play button)

3. First build takes 30-60 seconds

4. You should see:
   - ✅ Build Succeeded
   - ✅ Simulator launches
   - ✅ Beautiful blue gradient login screen
   - ✅ "Trusenda" branding
   - ✅ Email & password fields

---

## Troubleshooting

### Error: "Cannot find TrusendaCRMApp in scope"

**Fix**: Make sure `TrusendaCRMApp.swift` exists and has `@main` annotation:

1. Open `TrusendaCRMApp.swift`
2. Verify it contains:
```swift
import SwiftUI

@main
struct TrusendaCRMApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
```

### Error: "No such module 'SwiftUI'"

**Fix**: Check deployment target

1. Project settings → General tab
2. Set **Minimum Deployments → iOS** to **16.0**

### Build errors in Swift files

**Fix**: Clean and rebuild

1. Press **Shift + ⌘ + K** (Clean Build Folder)
2. Press **⌘ + B** (Build)

### Files appear but can't be found during build

**Fix**: Files were added as references instead of groups

1. Select all files in Project Navigator
2. Delete them (don't move to trash, just remove references)
3. Re-add using steps 7-8 above
4. Make sure **"Copy items if needed"** is CHECKED

---

## Quick Verification Checklist

Before building, verify:

- [ ] All Swift files visible in Project Navigator
- [ ] All folder icons are BLUE (not yellow)
- [ ] `TrusendaCRMApp.swift` has `@main` annotation
- [ ] Deployment target is iOS 16.0+
- [ ] A simulator is selected (iPhone 16 Pro or similar)
- [ ] No red errors in the Issue Navigator (⌘ + 5)

---

## Success! 🎉

When the app runs, you'll see:

1. **Login Screen** with gradient background
2. Email and password fields
3. "Sign In" button
4. Can test with production backend at https://trusenda.com

---

**Total Time**: 5 minutes
**Difficulty**: Easy
**Success Rate**: 99% (if you follow steps exactly)

💡 **Tip**: Save this project as a template for future iOS projects!

