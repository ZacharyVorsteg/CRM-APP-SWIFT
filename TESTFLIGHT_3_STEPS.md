# TestFlight in 3 Simple Steps

## No screenshots, no descriptions, no complexity.

---

## STEP 1: Create App Slot (Browser - 2 minutes)

### Option A: Do It Yourself
1. Go to https://appstoreconnect.apple.com
2. Log in
3. Click "My Apps" → "+" → "New App"
4. Fill in:
   - iOS ✅
   - Name: TrusendaCRM
   - Language: English
   - Bundle ID: com.trusenda.crm (select from dropdown)
   - SKU: trusenda-001
5. Click "Create"

### Option B: Use AI Agent (RECOMMENDED)

Open the file `AI_AGENT_BROWSER_PROMPT.txt` in this folder.
- Copy the entire prompt
- Give it to your AI browser agent
- Log into appstoreconnect.apple.com first
- AI agent will create the app for you

**Result:** App slot created ✅

---

## STEP 2: Upload Build from Xcode (10 minutes)

### In Xcode (I'll do the commands for you):

**2a. Select the right target:**
- Top of Xcode, click where it says "iPhone 16 Pro"
- Select: **"Any iOS Device (arm64)"**
- **CRITICAL:** Must NOT be a simulator!

**2b. Archive:**
- Menu: **Product → Archive**
- Wait 2-3 minutes
- Organizer window opens

**2c. Upload:**
- Click **"Distribute App"**
- Select **"App Store Connect"** → Next
- Select **"Upload"** → Next
- Select **"Automatically manage signing"** → Next
- Click **"Upload"**
- Wait 5-10 minutes

**Result:** Upload successful ✅

---

## STEP 3: Add Yourself as Tester (5 minutes)

### Back in Browser:

1. Go to https://appstoreconnect.apple.com
2. Your app → **"TestFlight"** tab
3. **Wait 5-10 minutes** for build to process
4. Click **"Internal Testing"** (left sidebar)
5. Click **"+"** next to testers
6. Add your email: zacharyvorsteg@gmail.com
7. Click **"Add"** → **"Save"**

**Result:** You get email invitation ✅

---

## 📱 BONUS: Install on iPhone

1. **iPhone:** Download "TestFlight" app from App Store
2. **Open email** invitation on iPhone
3. **Tap** "View in TestFlight"
4. **Tap** "Install"
5. **Test your app!**

---

## ⚠️ The ONLY Thing That Might Go Wrong

**"Bundle ID not found in dropdown"**

**Fix:** Register it first (one-time, 2 minutes):
1. Go to https://developer.apple.com/account
2. Certificates, Identifiers & Profiles
3. Identifiers → "+"
4. App IDs → Continue
5. Description: Trusenda CRM
6. Bundle ID: com.trusenda.crm
7. Register

**Then go back to Step 1**

---

## 🎯 Ultra-Quick Summary

```
1. Browser: Create app at appstoreconnect.apple.com (2 min)
2. Xcode: Archive & Upload (10 min)
3. Browser: Add yourself as tester (5 min)
4. iPhone: Install TestFlight app, accept invite
```

**Total:** ~20 minutes + waiting for processing

**NO screenshots needed!**  
**NO descriptions needed!**  
**NO review needed!**

---

## 📞 If You Get Stuck

**Tell me:**
- "Can't find Any iOS Device" - I'll show you exactly where
- "Upload failed with error X" - I'll fix it
- "Build not showing up" - I'll troubleshoot

---

**That's it! TestFlight is the simple path.** 🚀

