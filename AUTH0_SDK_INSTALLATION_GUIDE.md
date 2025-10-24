# 📦 Auth0 Swift SDK Installation Guide

**Date:** October 24, 2025  
**For:** Trusenda CRM iOS App  
**Critical:** Follow these steps exactly to enable Google/Apple Sign-In

---

## 🎯 Overview

This guide will walk you through installing the Auth0 Swift SDK using Swift Package Manager (SPM) in Xcode. The SDK is required for social login functionality.

---

## ✅ Prerequisites

- ✅ Xcode 14.0 or later
- ✅ iOS 16.0+ deployment target
- ✅ Mac with internet connection
- ✅ TrusendaCRM.xcodeproj open in Xcode

---

## 📋 Step-by-Step Installation

### Step 1: Open Package Dependencies

1. **Open Xcode**
2. **Open project:** `/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM.xcodeproj`
3. **Click:** `File` → `Add Package Dependencies...`

**Screenshot moment:** You'll see a sheet titled "Add Packages to "TrusendaCRM"

---

### Step 2: Add Auth0.swift Repository

In the search bar at the top right, enter:

```
https://github.com/auth0/Auth0.swift
```

**EXACT URL (copy this):**
```
https://github.com/auth0/Auth0.swift
```

Press `Enter` or click the search icon.

---

### Step 3: Select Version

The Auth0.swift package will appear in the list. Configure the version:

**Dependency Rule:**
- Select: **"Up to Next Major Version"**
- Version: **3.0.0** (or latest 3.x.x)

**Why 3.x?**
- Version 3.x uses async/await (matches our code)
- Version 2.x uses completion handlers (outdated)
- Version 3.5.0 is current as of Oct 2024

---

### Step 4: Add to Target

1. Click **"Add Package"** button (bottom right)
2. Wait for package resolution (10-30 seconds)
3. **Select target:** Check the box next to **"TrusendaCRM"**
4. **Products to add:** Make sure **"Auth0"** is selected
5. Click **"Add Package"** again

---

### Step 5: Verify Installation

After installation completes:

1. In Xcode's Project Navigator (left sidebar), expand:
   - **TrusendaCRM** (project root)
   - **Package Dependencies**
   - You should see **"Auth0"** listed

2. Build the project to verify:
   ```
   Cmd + B
   ```

3. Check for errors:
   - ✅ **"Build Succeeded"** = SDK installed correctly!
   - ❌ **Build errors** = See troubleshooting below

---

## 🧪 Test Installation

### Quick Test (in Xcode):

1. Open any Swift file
2. Add at the top:
   ```swift
   import Auth0
   ```
3. Press `Cmd + B` to build
4. **No errors?** ✅ SDK is installed!

---

## 🛠️ Troubleshooting

### Issue: "No such module 'Auth0'"

**Cause:** SDK not added to target

**Fix:**
1. Select project in navigator
2. Select "TrusendaCRM" target
3. Go to "General" tab
4. Scroll to "Frameworks, Libraries, and Embedded Content"
5. Click `+` button
6. Select "Auth0" from list
7. Click "Add"

---

### Issue: Package resolution fails

**Cause:** Network issue or GitHub rate limit

**Fix:**
1. Check internet connection
2. Wait 5 minutes and try again
3. Or download manually:
   ```bash
   cd /Users/zachthomas/Desktop/CRM-APP-SWIFT
   git clone https://github.com/auth0/Auth0.swift.git
   ```
4. Then drag `Auth0.swift` folder into Xcode

---

### Issue: "The package product 'Auth0' requires minimum platform version"

**Cause:** Deployment target too low

**Fix:**
1. Select project in navigator
2. Select "TrusendaCRM" target
3. Go to "General" tab
4. Set "Minimum Deployments" to **iOS 16.0** or higher

---

### Issue: Build errors after adding package

**Cause:** Conflicting package versions

**Fix:**
1. `File` → `Packages` → `Reset Package Caches`
2. `File` → `Packages` → `Update to Latest Package Versions`
3. Clean build folder: `Cmd + Shift + K`
4. Rebuild: `Cmd + B`

---

## 📦 Package Information

**Package:** Auth0.swift  
**Repository:** https://github.com/auth0/Auth0.swift  
**Current Version:** 3.5.0 (as of Oct 2024)  
**License:** MIT  
**Maintainer:** Auth0, Inc.

**What it includes:**
- Web authentication (ASWebAuthenticationSession)
- Credentials management
- Token refresh
- User profile API
- PKCE support (secure mobile auth)

---

## ✅ Post-Installation Checklist

After installing the SDK:

- [x] **Auth0.swift appears in Package Dependencies**
- [x] **Project builds without errors (`Cmd + B`)**
- [x] **`import Auth0` works in Swift files**
- [ ] **Info.plist updated with URL scheme** (already done ✅)
- [ ] **Auth0Config.swift has correct credentials** (already done ✅)
- [ ] **Auth0Manager.swift exists** (already done ✅)
- [ ] **LoginView imports Auth0** (already done ✅)

---

## 🎯 Next Steps

After SDK installation:

1. ✅ **Build project** to ensure no errors
2. ✅ **Update Auth0 dashboard** (see `AUTH0_DASHBOARD_SETUP_GUIDE.md`)
3. ✅ **Test Google Sign-In** on real device or simulator
4. ✅ **Test Apple Sign-In** on real device only (doesn't work in simulator)
5. ✅ **Deploy to TestFlight** for beta testing

---

## 🔍 How to Verify It's Working

### Visual Verification:

1. **Run app in simulator:** `Cmd + R`
2. **Login screen should show:**
   - ✅ "Continue with Google" button (blue gradient)
   - ✅ "Continue with Apple" button (black gradient)
   - ✅ "or" divider
   - ✅ Email/password form below

3. **Tap "Continue with Google":**
   - ✅ Safari authentication sheet opens
   - ✅ Shows Auth0 Universal Login page
   - ✅ Google sign-in option available

### Console Logs:

When the SDK is working, you'll see in Xcode console:

```
🔧 Auth0Manager initialized
🔐 ============ AUTH0 CONFIGURATION ============
🔐 Domain: dev-8shke7zmn4ginkyi.us.auth0.com
🔐 Client ID: ZJMn8FKY...
🔐 Is Configured: ✅ YES
🔐 ==============================================
```

---

## 📱 Testing Requirements

### Simulator Testing:
- ✅ **Google Sign-In:** Works in simulator
- ❌ **Apple Sign-In:** Does NOT work in simulator (Apple restriction)

### Device Testing:
- ✅ **Google Sign-In:** Works on device
- ✅ **Apple Sign-In:** Works on device with Apple ID

**Tip:** Use Google Sign-In for initial testing in simulator!

---

## 🚀 Deployment Notes

### TestFlight Requirements:

When submitting to TestFlight:
1. ✅ SDK is embedded automatically (no manual steps)
2. ✅ Auth0 credentials in code (not in Info.plist)
3. ✅ URL scheme registered in Info.plist
4. ✅ App capabilities configured (if needed)

### App Store Submission:

No special steps required! Auth0.swift is:
- ✅ Open source (MIT license)
- ✅ App Store compliant
- ✅ Used by thousands of apps
- ✅ No privacy concerns

---

## 📞 Support

### If you get stuck:

1. **Check Xcode console** for detailed error messages
2. **Review troubleshooting section** above
3. **Check Auth0.swift docs:** https://github.com/auth0/Auth0.swift
4. **Verify package is added to target** (common issue!)

### Common Success Indicators:

- ✅ Package appears in "Package Dependencies"
- ✅ Build succeeds (`Cmd + B`)
- ✅ `import Auth0` works
- ✅ Social buttons appear on login screen
- ✅ Console shows "Auth0Manager initialized"

---

## ⚡ Quick Install (Copy-Paste Checklist)

Use this checklist during installation:

```
1. [ ] Open Xcode
2. [ ] File → Add Package Dependencies
3. [ ] Paste URL: https://github.com/auth0/Auth0.swift
4. [ ] Select version: Up to Next Major 3.0.0
5. [ ] Click "Add Package"
6. [ ] Wait for resolution
7. [ ] Check "TrusendaCRM" target
8. [ ] Click "Add Package" again
9. [ ] Verify in Package Dependencies
10. [ ] Build project (Cmd + B)
11. [ ] Check console for "Auth0Manager initialized"
12. [ ] Run app and verify social buttons appear
```

---

## 🎉 Success!

Once installed, the Auth0 SDK will enable:
- ✅ Google Sign-In (one-tap)
- ✅ Apple Sign-In (native iOS)
- ✅ Email/password via Auth0
- ✅ Persistent sessions
- ✅ Automatic token refresh
- ✅ Cloud/iOS feature parity

**You've successfully installed the Auth0 Swift SDK!** 🚀

Now proceed to `AUTH0_DASHBOARD_SETUP_GUIDE.md` to configure the Auth0 dashboard for iOS.

