# 🔧 Auth0 Dashboard Setup Guide for iOS

**Date:** October 24, 2025  
**For:** Trusenda CRM iOS App  
**Critical:** Configure callback URLs for iOS app authentication

---

## 🎯 Overview

This guide configures your Auth0 application to accept authentication requests from the iOS app. Without these settings, iOS authentication will fail with "Invalid Callback URL" errors.

---

## 📋 Prerequisites

- ✅ Auth0 account created
- ✅ Auth0 application configured for cloud app
- ✅ iOS app's `Info.plist` updated with URL scheme (✅ already done)
- ✅ Auth0Config.swift has correct credentials (✅ already done)

---

## 🔐 Auth0 Dashboard Access

### Step 1: Log In

1. **Navigate to:** https://manage.auth0.com
2. **Log in** with your Auth0 account
3. **Select** your tenant (dev-8shke7zmn4ginkyi)

---

## 🎯 Application Configuration

### Step 2: Open Application Settings

1. **Click** "Applications" in the left sidebar
2. **Find** "Trusenda" application
3. **Click** on the application name
4. **Click** "Settings" tab (between Quickstart and Addons)

---

## 📱 iOS Callback URL Configuration

### Step 3: Add iOS Callback URLs

Scroll down to the **"Application URIs"** section.

**Find:** "Allowed Callback URLs" field

**CRITICAL:** You must add the iOS callback URL to the **EXISTING** list. Do not remove the cloud URLs!

### Current Cloud URLs (keep these):
```
https://trusenda.com/callback,https://www.trusenda.com/callback,https://trusenda.netlify.app/callback,http://localhost:5173/callback
```

### iOS URL to Add:
```
com.trusenda.crm://dev-8shke7zmn4ginkyi.us.auth0.com/ios/com.trusenda.TrusendaCRM/callback
```

### Complete List (copy this exactly):
```
https://trusenda.com/callback,https://www.trusenda.com/callback,https://trusenda.netlify.app/callback,http://localhost:5173/callback,com.trusenda.crm://dev-8shke7zmn4ginkyi.us.auth0.com/ios/com.trusenda.TrusendaCRM/callback
```

**Or add one URL per line:**
```
https://trusenda.com/callback
https://www.trusenda.com/callback
https://trusenda.netlify.app/callback
http://localhost:5173/callback
com.trusenda.crm://dev-8shke7zmn4ginkyi.us.auth0.com/ios/com.trusenda.TrusendaCRM/callback
```

---

### Step 4: Add iOS Logout URLs

Find: **"Allowed Logout URLs"** field

### Current Cloud URLs (keep these):
```
https://trusenda.com,https://www.trusenda.com,https://trusenda.netlify.app,http://localhost:5173
```

### iOS URL to Add:
```
com.trusenda.crm://dev-8shke7zmn4ginkyi.us.auth0.com/ios/com.trusenda.TrusendaCRM/logout
```

### Complete List (copy this exactly):
```
https://trusenda.com,https://www.trusenda.com,https://trusenda.netlify.app,http://localhost:5173,com.trusenda.crm://dev-8shke7zmn4ginkyi.us.auth0.com/ios/com.trusenda.TrusendaCRM/logout
```

**Or add one URL per line:**
```
https://trusenda.com
https://www.trusenda.com
https://trusenda.netlify.app
http://localhost:5173
com.trusenda.crm://dev-8shke7zmn4ginkyi.us.auth0.com/ios/com.trusenda.TrusendaCRM/logout
```

---

### Step 5: Add iOS Web Origins

Find: **"Allowed Web Origins"** field

### Current Cloud URLs (keep these):
```
https://trusenda.com,https://www.trusenda.com,https://trusenda.netlify.app,http://localhost:5173
```

### iOS URL to Add:
```
file://
```

### Complete List (copy this exactly):
```
https://trusenda.com,https://www.trusenda.com,https://trusenda.netlify.app,http://localhost:5173,file://
```

**Why `file://`?**
- iOS WebView authentication uses `file://` origin
- Required for ASWebAuthenticationSession
- Standard for mobile apps

---

## 💾 Save Changes

### Step 6: Save Configuration

**CRITICAL:** Scroll to the **BOTTOM** of the Settings page

1. **Click** "Save Changes" button (bottom right)
2. **Wait** for "Saved successfully" confirmation message
3. **Verify** the confirmation appears

**⚠️ Changes do NOT take effect until you save!**

---

## ✅ Verification

### Visual Verification:

After saving, the "Application URIs" section should show:

```
Allowed Callback URLs:
https://trusenda.com/callback, https://www.trusenda.com/callback, https://trusenda.netlify.app/callback, http://localhost:5173/callback, com.trusenda.crm://dev-8shke7zmn4ginkyi.us.auth0.com/ios/com.trusenda.TrusendaCRM/callback

Allowed Logout URLs:
https://trusenda.com, https://www.trusenda.com, https://trusenda.netlify.app, http://localhost:5173, com.trusenda.crm://dev-8shke7zmn4ginkyi.us.auth0.com/ios/com.trusenda.TrusendaCRM/logout

Allowed Web Origins:
https://trusenda.com, https://www.trusenda.com, https://trusenda.netlify.app, http://localhost:5173, file://
```

---

## 🔍 Double-Check Connections

### Step 7: Verify Social Connections

1. **Click** "Connections" tab (next to Settings)
2. **Verify** these are enabled:
   - ✅ **Username-Password-Authentication:** Enabled
   - ✅ **Google:** Enabled (google-oauth2)
   - ✅ **Apple:** Enabled (apple)

**If disabled:**
1. Click "Authentication" in left sidebar
2. Click "Social"
3. Enable Google and Apple connections
4. Configure each with required credentials

---

## 🧪 Test Configuration

### Test 1: Run iOS App

1. **Build and run** iOS app in Xcode (`Cmd + R`)
2. **Navigate** to login screen
3. **Verify** social buttons appear:
   - ✅ "Continue with Google" (blue button)
   - ✅ "Continue with Apple" (black button)

### Test 2: Initiate Google Sign-In

1. **Tap** "Continue with Google" button
2. **Verify** Safari authentication sheet opens
3. **Verify** Auth0 Universal Login page loads
4. **Verify** Google sign-in option available
5. **Select** Google account
6. **Complete** authentication
7. **Verify** redirect back to app (not error)

### Expected Flow:
```
iOS App → Safari Sheet → Auth0 Login → Google OAuth → Auth0 Callback → iOS App (Authenticated) ✅
```

### Common Errors:
- ❌ **"Invalid Callback URL"** → URLs not saved in dashboard
- ❌ **"Unknown Client"** → Client ID mismatch
- ❌ **"Not Found"** → Domain typo
- ❌ **Sheet opens then closes immediately** → URL scheme not in Info.plist

---

## 🛠️ Troubleshooting

### Error: "Invalid Callback URL"

**Cause:** iOS callback URL not registered in Auth0

**Fix:**
1. Go back to Auth0 Dashboard → Applications → Trusenda → Settings
2. Verify iOS callback URL is in "Allowed Callback URLs"
3. Click "Save Changes" at bottom
4. Wait 30 seconds for changes to propagate
5. Try again

---

### Error: "Unknown client"

**Cause:** Client ID mismatch

**Fix:**
1. In Auth0 Dashboard, copy the **Client ID** from "Basic Information" section
2. Open `Auth0Config.swift` in Xcode
3. Verify `clientId` matches exactly
4. Rebuild app (`Cmd + Shift + K`, then `Cmd + B`)

---

### Error: Safari sheet opens then closes immediately

**Cause:** URL scheme not registered in Info.plist

**Fix:**
1. Open `Info.plist` in Xcode
2. Verify `CFBundleURLSchemes` contains `com.trusenda.crm`
3. **Already done for you!** ✅
4. If missing, see `Info.plist` section in `IOS_AUTH0_IMPLEMENTATION_STATUS.md`

---

### Error: "Connection was reset"

**Cause:** Network issue or Auth0 tenant misconfiguration

**Fix:**
1. Check internet connection
2. Verify Auth0 tenant is active (not suspended)
3. Try again in a few minutes
4. Check Auth0 status page: https://status.auth0.com

---

## 📊 Application Type Settings

### Verify Application Type:

In the Settings tab, find **"Application Type"** section:

**Should be set to:**
- ✅ **Single Page Application (SPA)**

**If different:**
- Native application type also works for mobile
- SPA is preferred for cloud/mobile parity

**Token Endpoint Authentication Method:**
- ✅ **None** (for SPA)
- ✅ **POST** (for Native)

---

## 🔐 Grant Types

### Verify Grant Types:

In the Settings tab, find **"Advanced Settings"** → **"Grant Types"**

**Required for iOS:**
- ✅ **Authorization Code** (required for auth0.swift SDK)
- ✅ **Implicit** (optional, for web fallback)
- ✅ **Refresh Token** (required for persistent sessions)

**Optional:**
- ⬜ **Client Credentials** (not needed for mobile)
- ⬜ **Password** (not needed if using web auth)

---

## 🎨 Branding (Optional)

### Customize Universal Login:

1. **Click** "Branding" in left sidebar
2. **Click** "Universal Login"
3. **Customize:**
   - Logo: Upload Trusenda logo
   - Primary Color: #005EC7 (Salesforce blue)
   - Background: Custom gradient or image

**Benefits:**
- Professional branded experience
- Consistent with your app
- Builds trust with users

---

## 📱 Testing Checklist

After configuration, verify these work:

- [ ] **iOS app shows social buttons** on login screen
- [ ] **"Continue with Google" opens Safari auth sheet**
- [ ] **Auth0 Universal Login page loads**
- [ ] **Can select Google account**
- [ ] **Redirects back to iOS app after auth**
- [ ] **User is logged in (sees main app)**
- [ ] **User profile data loaded correctly**
- [ ] **Logout works (clears session)**
- [ ] **Cloud app still works** (not affected by iOS changes)

---

## 🚀 Production Considerations

### Before App Store Submission:

1. ✅ **Remove localhost URLs** from callback URLs (keep for development)
2. ✅ **Verify production domain** (trusenda.com) is primary
3. ✅ **Test on real device** (not just simulator)
4. ✅ **Test Apple Sign In** (requires real device)
5. ✅ **Test both Google and Apple** sign-in flows
6. ✅ **Test logout** completely clears session
7. ✅ **Test token refresh** (wait 1 hour, use app again)

---

## 🔄 Rollback Plan

If something goes wrong:

### To Revert iOS Changes:

1. **Remove iOS URLs** from Auth0 dashboard
2. **Click "Save Changes"**
3. **Cloud app continues working** (unaffected)
4. **iOS app falls back** to Netlify Identity

**Note:** Dual authentication system means:
- ✅ Existing Netlify users unaffected
- ✅ Can disable Auth0 without breaking app
- ✅ No forced migration

---

## 📞 Support

### If you get stuck:

1. **Check Auth0 Logs:**
   - Dashboard → Monitoring → Logs
   - Look for failed authentication attempts
   - Error messages explain what went wrong

2. **Check iOS Console:**
   - Xcode → View → Debug Area → Show Debug Area
   - Look for Auth0-related errors
   - Look for callback URL mismatches

3. **Common Issues:**
   - Forgot to click "Save Changes" (most common!)
   - Typo in callback URL
   - Wrong client ID in code
   - URL scheme not in Info.plist

---

## ✅ Configuration Complete!

Once you see this checklist completed:

- [x] **iOS callback URL added to Auth0 dashboard**
- [x] **iOS logout URL added to Auth0 dashboard**
- [x] **iOS web origin added (file://)**
- [x] **Changes saved in Auth0 dashboard**
- [x] **Connections verified (Google, Apple enabled)**
- [x] **Application type correct (SPA or Native)**
- [x] **Grant types include Authorization Code + Refresh Token**
- [ ] **Tested Google Sign-In on iOS** (do this next!)
- [ ] **Tested Apple Sign-In on iOS device** (do this next!)

---

## 🎯 Next Steps

1. ✅ **Test authentication** (see testing guide)
2. ✅ **Monitor Auth0 logs** for successful logins
3. ✅ **Test token refresh** (use app after 1 hour)
4. ✅ **Test logout** flow
5. ✅ **Deploy to TestFlight** for beta testing

---

**Your Auth0 dashboard is now configured for iOS authentication!** 🚀

Proceed to testing the authentication flows in your iOS app.

