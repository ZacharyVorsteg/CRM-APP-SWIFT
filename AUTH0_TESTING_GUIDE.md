# 🧪 Auth0 Testing Guide - iOS App

**Date:** October 24, 2025  
**For:** Trusenda CRM iOS App  
**Purpose:** Comprehensive testing guide for Auth0 social authentication

---

## 🎯 Overview

This guide provides step-by-step instructions for testing all Auth0 authentication flows in the iOS app. Follow these tests in order to ensure everything works correctly before deploying to production.

---

## 📋 Pre-Testing Checklist

Before you begin testing, verify:

- [ ] **Auth0 SDK installed** via Swift Package Manager
- [ ] **Project builds without errors** (`Cmd + B`)
- [ ] **Info.plist has URL scheme** (`com.trusenda.crm`)
- [ ] **Auth0Config.swift has correct credentials**
- [ ] **Auth0 dashboard configured** with iOS callback URLs
- [ ] **LoginView shows social buttons** in UI

---

## 🧪 Test Suite

### Test 1: Visual Verification

**Purpose:** Verify UI shows Auth0 buttons correctly

**Steps:**
1. **Build and run** app in Xcode (`Cmd + R`)
2. **Navigate** to login screen
3. **Verify** the following appear:
   - ✅ "Continue with Google" button (blue gradient)
   - ✅ "Continue with Apple" button (black gradient)
   - ✅ "or" divider text
   - ✅ Email/password form below

**Expected Result:**
- Social buttons visible and styled correctly
- Buttons respond to tap (visual feedback)
- Form still accessible below buttons

**Console Check:**
```
🔧 Auth0Manager initialized
🔐 ============ AUTH0 CONFIGURATION ============
🔐 Domain: dev-8shke7zmn4ginkyi.us.auth0.com
🔐 Client ID: ZJMn8FKY...
🔐 Is Configured: ✅ YES
🔐 ==============================================
```

**Status:** [ ] Pass [ ] Fail

---

### Test 2: Google Sign-In (Simulator)

**Purpose:** Test Google OAuth flow

**Device:** iPhone Simulator (any iOS 16+)

**Steps:**
1. **Tap** "Continue with Google" button
2. **Observe** Safari authentication sheet opens
3. **Verify** Auth0 Universal Login page loads
4. **Check** Console for logs:
   ```
   🔐 ========== GOOGLE LOGIN ==========
   🔐 Connection: google-oauth2
   🔐 Domain: dev-8shke7zmn4ginkyi.us.auth0.com
   🔐 ===================================
   ```
5. **Select** Google account or sign in
6. **Observe** after authentication:
   - Sheet shows callback redirect
   - App receives callback
   - User is authenticated

**Expected Console Output (Success):**
```
✅ ========== GOOGLE LOGIN SUCCESS ==========
✅ Access Token received: [token...]
✅ ID Token received: [token...]
✅ Has Refresh Token: true
✅ ============================================
✅ User profile fetched successfully
✅ Email: [user@gmail.com]
✅ Name: [User Name]
✅ User authenticated successfully
```

**Expected Result:**
- ✅ Safari sheet opens with Auth0 login
- ✅ Google OAuth flow completes
- ✅ Redirects back to app
- ✅ User sees main dashboard
- ✅ Profile loaded (check Settings)

**Status:** [ ] Pass [ ] Fail

---

### Test 3: Apple Sign-In (Real Device Only)

**Purpose:** Test Apple Sign In with biometric auth

**Device:** Real iPhone (Simulator does NOT support Apple Sign In)

**Requirements:**
- Real device signed in with Apple ID
- Face ID or Touch ID enabled

**Steps:**
1. **Build** to real device
2. **Tap** "Continue with Apple" button
3. **Observe** Apple Sign In sheet (native iOS)
4. **Authenticate** with Face ID/Touch ID
5. **Observe** App receives callback
6. **Verify** User authenticated

**Expected Console Output (Success):**
```
🔐 ========== APPLE LOGIN ==========
🔐 Connection: apple
🔐 Domain: dev-8shke7zmn4ginkyi.us.auth0.com
🔐 ===================================
✅ ========== APPLE LOGIN SUCCESS ==========
✅ Access Token received: [token...]
✅ User authenticated successfully
```

**Expected Result:**
- ✅ Native Apple Sign In sheet appears
- ✅ Face ID/Touch ID prompt
- ✅ Quick authentication (1-2 seconds)
- ✅ Seamless return to app
- ✅ User sees dashboard

**Status:** [ ] Pass [ ] Fail

---

### Test 4: Email/Password (Fallback)

**Purpose:** Verify Netlify Identity still works

**Steps:**
1. **Enter** email and password (existing account)
2. **Tap** "Sign In" button
3. **Verify** login works

**Expected Result:**
- ✅ Netlify Identity authentication still functional
- ✅ Existing users unaffected
- ✅ No breaking changes

**Status:** [ ] Pass [ ] Fail

---

### Test 5: API Calls with Auth0 Token

**Purpose:** Verify backend accepts Auth0 tokens

**Prerequisite:** Logged in via Google or Apple

**Steps:**
1. **After auth**, navigate to Leads tab
2. **Observe** leads load successfully
3. **Create** a new lead
4. **Verify** lead saves

**Expected Console Output:**
```
🔐 ========== ADDING AUTH HEADER ==========
🔐 Using Auth0 access token
🔐 Token length: [X] characters
🔐 Provider: Google (or Apple)
🔐 =========================================
```

**Expected Result:**
- ✅ API calls succeed with Auth0 token
- ✅ Backend accepts token
- ✅ Data loads correctly
- ✅ CRUD operations work

**Status:** [ ] Pass [ ] Fail

---

### Test 6: Token Refresh

**Purpose:** Verify automatic token refresh

**Steps:**
1. **Log in** via Google/Apple
2. **Wait** 1 hour (or force token expiration)
3. **Make API call** (navigate to different tab)
4. **Observe** token refreshes automatically

**Expected Console Output:**
```
🔄 ========== REFRESHING TOKEN ==========
🔄 Using stored refresh token
✅ Token refreshed successfully
✅ New token length: [X] characters
🔄 ========================================
```

**Expected Result:**
- ✅ Token refreshes silently
- ✅ User stays authenticated
- ✅ No re-login required
- ✅ API calls continue working

**Status:** [ ] Pass [ ] Fail

---

### Test 7: Logout

**Purpose:** Verify complete session clearing

**Prerequisite:** Logged in via Auth0

**Steps:**
1. **Navigate** to Settings
2. **Tap** "Logout" button
3. **Observe** logout process
4. **Verify** return to login screen

**Expected Console Output:**
```
👋 ========== LOGGING OUT ==========
👋 Clearing tokens from keychain
👋 Logging out of Auth0
👋 ===================================
✅ Logged out of Auth0 successfully
✅ Local session cleared
```

**Expected Result:**
- ✅ Auth0 session cleared
- ✅ Keychain tokens deleted
- ✅ Returns to login screen
- ✅ Cannot access app without login

**Status:** [ ] Pass [ ] Fail

---

### Test 8: Persistent Sessions

**Purpose:** Verify user stays logged in

**Steps:**
1. **Log in** via Google/Apple
2. **Close app** completely (swipe up from app switcher)
3. **Reopen app**
4. **Verify** user still logged in (no login screen)

**Expected Console Output:**
```
🔄 ========== RESTORING AUTH0 SESSION ==========
✅ Found stored access token
✅ Session restored successfully
🔄 ==============================================
```

**Expected Result:**
- ✅ User stays logged in
- ✅ No flash of login screen
- ✅ Smooth app launch
- ✅ Matches cloud behavior

**Status:** [ ] Pass [ ] Fail

---

### Test 9: New User Sign-Up

**Purpose:** Test account creation flow

**Steps:**
1. **Tap** "Create Account" on login screen
2. **Enter** new email and password
3. **Accept** terms and conditions
4. **Tap** "Create Account"
5. **Verify** auto-login after signup

**Expected Result:**
- ✅ Account created successfully
- ✅ Auto-login works
- ✅ Welcome screen shows for new user
- ✅ Can create first lead

**Status:** [ ] Pass [ ] Fail

---

### Test 10: Multiple Account Switching

**Purpose:** Verify can switch between accounts

**Steps:**
1. **Log in** with Google Account A
2. **Logout**
3. **Log in** with different Google Account B
4. **Verify** correct account data loads

**Expected Result:**
- ✅ Can switch accounts
- ✅ Correct profile loads
- ✅ Correct leads load
- ✅ No data mixing

**Status:** [ ] Pass [ ] Fail

---

## 🛠️ Troubleshooting Tests

### Debug Test 1: Invalid Callback URL

**Purpose:** Test error handling for misconfigured URLs

**Setup:** Temporarily break callback URL in Auth0Config.swift

**Expected:**
- ❌ Error message in console
- ❌ Safari sheet closes immediately
- ✅ App doesn't crash

---

### Debug Test 2: Network Failure

**Purpose:** Test offline behavior

**Setup:** Enable Airplane Mode

**Expected:**
- ✅ Graceful error message
- ✅ "No internet connection" alert
- ✅ Can retry when online

---

### Debug Test 3: Token Expiration

**Purpose:** Test expired token handling

**Setup:** Force token expiration (change expiry time)

**Expected:**
- ✅ Automatic refresh attempt
- ✅ Falls back to logout if refresh fails
- ✅ User prompted to log in again

---

## 📊 Test Results Summary

### Authentication Methods:

- [ ] **Google Sign-In (Simulator)**
- [ ] **Google Sign-In (Device)**
- [ ] **Apple Sign-In (Device)**
- [ ] **Email/Password (Netlify Identity)**

### Core Flows:

- [ ] **Login Flow**
- [ ] **Logout Flow**
- [ ] **Token Refresh**
- [ ] **Persistent Sessions**
- [ ] **API Calls with Auth0 Token**

### Error Handling:

- [ ] **Invalid Callback URL**
- [ ] **Network Failure**
- [ ] **Token Expiration**

### User Experience:

- [ ] **Social Buttons Appear**
- [ ] **Smooth Animations**
- [ ] **No Flash of Login Screen**
- [ ] **Welcome Screen for New Users**

---

## 🎯 Success Criteria

All tests must pass before deployment:

- ✅ **Google Sign-In works** on simulator and device
- ✅ **Apple Sign-In works** on real device
- ✅ **Netlify Identity works** (backward compatibility)
- ✅ **API calls succeed** with Auth0 tokens
- ✅ **Token refresh automatic**
- ✅ **Persistent sessions work**
- ✅ **Logout clears all sessions**
- ✅ **No crashes or errors**

---

## 📱 Device Testing Matrix

Test on multiple devices/OS versions:

| Device | iOS Version | Google Sign-In | Apple Sign-In |
|--------|-------------|----------------|---------------|
| iPhone 14 Pro | iOS 17.0 | [ ] Pass | [ ] Pass |
| iPhone 12 | iOS 16.0 | [ ] Pass | [ ] Pass |
| Simulator | iOS 17.0 | [ ] Pass | N/A |

---

## 🔍 Monitoring

### During Testing, Monitor:

1. **Xcode Console:**
   - Look for Auth0 log messages
   - Check for errors or warnings
   - Verify token flow

2. **Auth0 Dashboard Logs:**
   - Navigate to: Monitoring → Logs
   - Watch for successful logins
   - Check for failed attempts
   - Review error messages

3. **Network Traffic:**
   - Use Xcode Network Inspector
   - Verify API calls include Bearer token
   - Check for 401 errors

---

## 📝 Test Log Template

Copy this for each test session:

```
Test Session: [Date/Time]
Tester: [Name]
Device: [iPhone Model]
iOS Version: [X.X]
Build: [Build Number]

Test 1 - Visual: [ ] Pass [ ] Fail
Test 2 - Google: [ ] Pass [ ] Fail
Test 3 - Apple: [ ] Pass [ ] Fail
Test 4 - Email: [ ] Pass [ ] Fail
Test 5 - API: [ ] Pass [ ] Fail
Test 6 - Refresh: [ ] Pass [ ] Fail
Test 7 - Logout: [ ] Pass [ ] Fail
Test 8 - Persistent: [ ] Pass [ ] Fail

Issues Found:
1. [Description]
2. [Description]

Notes:
[Any observations]
```

---

## 🚀 Pre-Production Checklist

Before TestFlight or App Store:

- [ ] All tests pass on real device
- [ ] Tested on iOS 16.0+ (minimum)
- [ ] Both Google and Apple Sign-In work
- [ ] No console errors or warnings
- [ ] Auth0 dashboard shows successful logins
- [ ] Token refresh tested (1+ hour session)
- [ ] Logout fully clears session
- [ ] Multiple account switching works
- [ ] Backward compatibility verified (Netlify)
- [ ] Performance acceptable (< 3s login)

---

## 📞 Support

### If Tests Fail:

1. **Check Xcode Console** for detailed errors
2. **Review Auth0 Dashboard Logs**
3. **Verify configuration:**
   - Auth0Config.swift credentials
   - Info.plist URL scheme
   - Auth0 dashboard callback URLs
4. **Review setup guides:**
   - AUTH0_SDK_INSTALLATION_GUIDE.md
   - AUTH0_DASHBOARD_SETUP_GUIDE.md

---

## ✅ Testing Complete!

Once all tests pass:

- [ ] **Document test results**
- [ ] **Screenshot successful flows**
- [ ] **Note any issues or edge cases**
- [ ] **Deploy to TestFlight for beta testing**
- [ ] **Gather user feedback**

---

**Your Auth0 integration is fully tested and ready for production!** 🎉

Proceed to TestFlight deployment or App Store submission.

