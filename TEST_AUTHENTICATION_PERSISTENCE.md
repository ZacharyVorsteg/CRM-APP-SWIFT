# Authentication Persistence Testing Guide

**Date:** October 22, 2025  
**Priority:** CRITICAL  
**Status:** Ready for Testing

## Overview

This guide provides comprehensive test scenarios to verify that the authentication persistence fix is working correctly. Users should stay logged in across app sessions unless they manually log out.

## Prerequisites

- iOS device or simulator with the Trusenda CRM app installed
- Test account credentials
- Xcode console access for debug logs (optional but recommended)

## Test Scenarios

### ✅ Scenario 1: Fresh Install - First Login

**Steps:**
1. Install app (fresh install or after deletion)
2. Open app
3. Enter credentials and login

**Expected Behavior:**
- ✅ Login screen appears (no tokens in keychain)
- ✅ Login succeeds
- ✅ Splash screen appears (1.5s animation)
- ✅ Main app appears
- ✅ No login screen shown again

**Debug Logs:**
```
❌ No tokens found - requiring login
✅ Login successful! Token expires in 3600 seconds
✅ Session restored - user still logged in
```

---

### ✅ Scenario 2: Immediate App Reopen (Valid Access Token)

**Steps:**
1. Login successfully (Scenario 1)
2. Force close app (swipe up in app switcher)
3. Reopen app immediately (within 1 hour)

**Expected Behavior:**
- ✅ NO login screen shown
- ✅ Splash screen appears immediately (optimistic auth)
- ✅ Main app loads seamlessly
- ✅ All data loads normally
- ✅ User never sees login screen

**Debug Logs:**
```
🔐 Found stored tokens - initializing as authenticated
🔍 Checking authentication status...
✅ Valid access token found
✅ Session restored successfully
```

**CRITICAL:** If you see the login screen, this test FAILED.

---

### ✅ Scenario 3: App Reopen After Token Expiry (Automatic Refresh)

**Steps:**
1. Login successfully
2. Force close app
3. Wait 1+ hours (until access token expires)
4. Reopen app

**Expected Behavior:**
- ✅ NO login screen shown
- ✅ Splash screen appears (optimistic auth)
- ✅ Background token refresh happens automatically
- ✅ Main app loads with fresh token
- ✅ User never sees login screen

**Debug Logs:**
```
🔐 Found stored tokens - initializing as authenticated
🔍 Checking authentication status...
⚠️ Access token expired or invalid
🔄 Attempting automatic token refresh...
✅ Token refreshed and session restored
```

**CRITICAL:** This is the primary bug we fixed. User should NOT see login screen.

---

### ✅ Scenario 4: Manual Logout

**Steps:**
1. Login successfully
2. Navigate to Settings tab
3. Scroll down and tap "Logout" button
4. Confirm logout

**Expected Behavior:**
- ✅ App shows login screen immediately
- ✅ All tokens cleared from keychain
- ✅ User data cleared from memory
- ✅ Cannot access app without re-login

**Debug Logs:**
```
🗑️ Clearing all tokens
❌ No tokens found - requiring login
```

---

### ✅ Scenario 5: App Reopen After Logout

**Steps:**
1. Logout from Settings (Scenario 4)
2. Force close app
3. Reopen app

**Expected Behavior:**
- ✅ Login screen appears (no tokens)
- ✅ Must enter credentials to continue
- ✅ Cannot access app without login

**Debug Logs:**
```
❌ No tokens found - requiring login
```

---

### ✅ Scenario 6: Device Restart (Keychain Persistence)

**Steps:**
1. Login successfully
2. Restart iOS device (power off, power on)
3. Open app after restart

**Expected Behavior:**
- ✅ NO login screen shown
- ✅ Splash screen appears
- ✅ Session restored from keychain
- ✅ Tokens survive device restart

**Debug Logs:**
```
🔐 Found stored tokens - initializing as authenticated
✅ Session restored successfully
```

**Note:** iOS Keychain persists across device restarts.

---

### ✅ Scenario 7: Network Interruption During Token Refresh

**Steps:**
1. Login successfully
2. Force close app
3. Enable Airplane Mode
4. Reopen app
5. Disable Airplane Mode

**Expected Behavior:**
- ✅ App shows cached authenticated state initially
- ⚠️ Token refresh may fail (network error)
- ✅ App retries on next API call
- ✅ Eventually succeeds when network restored
- ℹ️ May show error toast for API failures

**Debug Logs:**
```
🔐 Found stored tokens - initializing as authenticated
🔍 Checking authentication status...
❌ Token refresh failed: [network error]
⚠️ All token restoration attempts failed - requiring login
```

**Note:** Network failures during refresh may require re-login.

---

### ✅ Scenario 8: Invalid Refresh Token (Backend Rejection)

**Steps:**
1. Login successfully
2. Manually corrupt refresh token in keychain (developer testing)
3. Force close app
4. Reopen app

**Expected Behavior:**
- ✅ App attempts token refresh
- ❌ Backend rejects invalid refresh token
- ⚠️ App clears all tokens
- ✅ Login screen appears (expected behavior)

**Debug Logs:**
```
🔐 Found stored tokens - initializing as authenticated
🔍 Checking authentication status...
⚠️ Access token expired or invalid
🔄 Attempting automatic token refresh...
❌ Token refresh failed: [401 Unauthorized]
⚠️ All token restoration attempts failed - requiring login
```

**Note:** This is expected behavior for security.

---

## Success Criteria

### ✅ MUST PASS (Critical)
- [ ] User stays logged in when reopening app immediately
- [ ] User stays logged in when reopening app after 1+ hours (auto-refresh)
- [ ] No flash of login screen when tokens exist
- [ ] Splash screen appears smoothly on reopen
- [ ] Manual logout works correctly
- [ ] Tokens persist across device restarts

### ✅ SHOULD PASS (Important)
- [ ] Debug logs show correct authentication flow
- [ ] Optimistic auth state prevents login screen flash
- [ ] Token refresh happens silently in background
- [ ] Network errors handled gracefully

### ⚠️ ACCEPTABLE FAILURES (Edge Cases)
- Network unavailable during token refresh → May require re-login
- Corrupt or invalid refresh token → Requires re-login (security)
- Server returns 401 for refresh token → Requires re-login (expected)

---

## Debug Logging

To see detailed authentication logs, run the app from Xcode and watch the console:

### Key Log Indicators

**✅ Successful Session Restore:**
```
🔐 Found stored tokens - initializing as authenticated
🔍 Checking authentication status...
✅ Valid access token found
✅ Session restored successfully
```

**🔄 Automatic Token Refresh:**
```
⚠️ Access token expired or invalid
🔄 Attempting automatic token refresh...
✅ Token refreshed and session restored
```

**❌ Login Required:**
```
❌ No tokens found - requiring login
```

**⚠️ Refresh Failed (Expected):**
```
❌ Token refresh failed: [error]
⚠️ All token restoration attempts failed - requiring login
```

---

## Common Issues & Solutions

### Issue: "App still shows login screen on reopen"

**Diagnosis:**
- Check if tokens are being saved to keychain
- Verify `isAuthenticated` is set to `true` on login
- Check if `checkAuthStatus()` is being called
- Look for premature `logout()` calls

**Solution:**
- Verify keychain permissions
- Check debug logs for token save failures
- Ensure auth state updates on main thread

---

### Issue: "App flashes login screen then shows main app"

**Diagnosis:**
- Optimistic auth state not working
- `isAuthenticated` starts as `false` instead of checking tokens

**Solution:**
- Verify `AuthManager.init()` checks for existing tokens
- Ensure `hasTokens` check includes refresh token

---

### Issue: "Token refresh fails with 401"

**Diagnosis:**
- Refresh token expired (30 days)
- Refresh token invalid or revoked
- Backend issue

**Solution:**
- This is EXPECTED behavior - user must re-login
- Only happens after 30 days of no app usage
- Or if user manually logs out on another device

---

## Manual Testing Checklist

```
[ ] Fresh install → Login works
[ ] Reopen immediately → No login screen ✅
[ ] Reopen after 1 hour → No login screen (auto-refresh) ✅
[ ] Manual logout → Login screen appears ✅
[ ] Reopen after logout → Login screen appears ✅
[ ] Device restart → Session persists ✅
[ ] Network error during refresh → Handled gracefully ⚠️
[ ] Invalid refresh token → Login required (security) ⚠️
[ ] Splash screen always shows (when authenticated) ✅
[ ] No flash of login screen ✅
```

---

## Automated Testing (Future)

Consider adding XCTest UI tests for these scenarios:

```swift
func testSessionPersistence() {
    // 1. Login
    login(email: testEmail, password: testPassword)
    
    // 2. Verify authenticated
    XCTAssertTrue(app.tabBars.exists)
    
    // 3. Terminate and relaunch
    app.terminate()
    app.launch()
    
    // 4. Verify still authenticated (no login screen)
    XCTAssertFalse(loginScreen.exists)
    XCTAssertTrue(app.tabBars.exists)
}
```

---

## Performance Metrics

**Target Timings:**
- Token check: < 100ms
- Token refresh: < 500ms
- Session restore: < 1s
- App launch to authenticated UI: < 2s

**Monitor for:**
- Slow token refresh blocking UI
- Multiple token refresh calls (should be 1)
- Excessive keychain reads

---

## Security Verification

**✅ Ensure:**
- Tokens never logged in production builds (`#if DEBUG`)
- Tokens stored in keychain (not UserDefaults)
- Keychain configured as device-bound (kSecAttrAccessibleWhenUnlocked)
- Token expiry respected (5-minute buffer)
- Refresh token rotated on refresh (if backend provides new one)

---

## Regression Testing

After any authentication changes, re-run ALL scenarios:

1. ✅ Fresh install login
2. ✅ Immediate reopen
3. ✅ Reopen after token expiry
4. ✅ Manual logout
5. ✅ Device restart
6. ⚠️ Network interruption
7. ⚠️ Invalid refresh token

---

## Production Readiness

**✅ READY TO DEPLOY** when:
- All critical scenarios pass
- No unexpected logouts reported
- Debug logs show correct flow
- Performance meets targets
- Security verified

**⚠️ DO NOT DEPLOY** if:
- Users see login screen on reopen (with valid tokens)
- Token refresh fails silently
- Tokens not persisting in keychain
- Security concerns identified

---

## Related Files

- `AUTHENTICATION_PERSISTENCE_FIX.md` - Implementation details
- `TrusendaCRM/Core/Network/AuthManager.swift` - Auth logic
- `TrusendaCRM/Core/Storage/KeychainManager.swift` - Token storage
- `AI_AGENT_BRIEFING.md` - Full context

---

## Support

If tests fail or issues arise:
1. Check debug logs in Xcode console
2. Verify keychain permissions
3. Review `AuthManager.swift` implementation
4. Test with fresh app install
5. Confirm backend token endpoints working

**Expected Outcome:** Users stay logged in indefinitely until manual logout. This matches cloud app behavior and provides optimal UX.

