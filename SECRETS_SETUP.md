# 🔒 Secrets Configuration for iOS

## Quick Start

The iOS app is pre-configured with your Auth0 and Apple credentials, but you can override them using a `Secrets.plist` file for additional security.

## Default Configuration (Already Set)

The following values are already configured in `Auth0Config.swift`:

```
Auth0 Domain: dev-8shke7zmn4ginkyi.us.auth0.com
Auth0 Client ID: ZJMn8FKYvWk7vof5Ry6pc0l0MaHhp8a7
Apple Team ID: 8746VPZ8R9
Apple Key ID: 4H3SA37DS2
Apple Client ID: com.trusenda
```

**The app will work immediately without creating Secrets.plist!**

## Optional: Use Secrets.plist for Enhanced Security

If you want to keep credentials out of source code:

### Step 1: Create Secrets.plist

1. Copy `Secrets.plist.template` to `Secrets.plist`
   ```bash
   cp Secrets.plist.template Secrets.plist
   ```

2. Add `Secrets.plist` to `.gitignore` (already done)

3. Add `Secrets.plist` to your Xcode project:
   - Drag `Secrets.plist` into Xcode
   - Make sure "Copy items if needed" is checked
   - Add to target: TrusendaCRM

### Step 2: Add Apple Signing Key (Optional)

⚠️ **Only needed if setting up Apple Sign-In from scratch**

1. Go to https://developer.apple.com
2. Certificates, Identifiers & Profiles → Keys
3. Create a new key (or use existing)
4. Download the `.p8` file
5. Open the `.p8` file in a text editor
6. Copy the entire contents (including BEGIN/END lines)
7. Paste into `Secrets.plist` under `APPLE_SIGNING_KEY`

**Example:**
```xml
<key>APPLE_SIGNING_KEY</key>
<string>-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...
(your actual key here)
-----END PRIVATE KEY-----</string>
```

### Step 3: Verify Configuration

Run the app and check Xcode console:

```
🔐 ============ AUTH0 CONFIGURATION ============
🔐 Domain: dev-8shke7zmn4ginkyi.us.auth0.com
🔐 Client ID: ZJMn8FKY...
🔐 Apple Signing Key: ✅ SET
🔐 Is Configured: ✅ YES
🔐 ==============================================
```

## Configuration Priority

The app loads configuration in this order:

1. **Secrets.plist** (if it exists and has the key)
2. **Fallback values in Auth0Config.swift** (pre-configured)

This means:
- App works immediately with default values
- You can override any value in Secrets.plist
- Secrets.plist is optional for development

## Security Best Practices

### ✅ DO:
- Add `Secrets.plist` to `.gitignore`
- Keep `.p8` files secure and never commit them
- Use Secrets.plist for production builds
- Store signing keys in keychain when possible

### ❌ DON'T:
- Commit `Secrets.plist` to git
- Share `.p8` files publicly
- Hardcode secrets in source code
- Include secrets in screenshots or logs

## Troubleshooting

### "Secrets.plist not found"
**Solution:** This is normal! The app uses fallback values from Auth0Config.swift.

### Apple Sign-In doesn't work
**Solution:** 
1. Make sure Apple Sign-In is enabled in Auth0 Dashboard
2. Configure Apple connection with your Team ID and Key ID
3. Add the signing key to Auth0 (not necessarily to Secrets.plist)

### Want to use different credentials?
**Solution:** Create Secrets.plist with your custom values

## Auth0 Dashboard Configuration

Make sure these URLs are configured in Auth0:

**Allowed Callback URLs:**
```
com.trusenda.crm://dev-8shke7zmn4ginkyi.us.auth0.com/ios/com.trusenda.TrusendaCRM/callback
```

**Allowed Logout URLs:**
```
com.trusenda.crm://dev-8shke7zmn4ginkyi.us.auth0.com/ios/com.trusenda.TrusendaCRM/logout
```

## Testing

1. Build and run the app
2. Check console for "🔐 Is Configured: ✅ YES"
3. Tap "Continue with Google" or "Continue with Apple"
4. Complete authentication
5. Check console for "✅ Login successful"

## Support

**Configuration already set! Just build and run!** 🚀

For issues:
- Check Auth0Config.swift for default values
- Check console logs for configuration details
- Verify callback URLs in Auth0 Dashboard

