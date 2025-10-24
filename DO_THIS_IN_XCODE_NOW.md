# 🎯 DO THIS IN XCODE RIGHT NOW (Manual Steps)

Xcode should be open with your workspace. Follow these EXACT steps:

---

## Step 1: Autocreate Schemes

In Xcode menu bar:

1. Click **"Product"**
2. Hover over **"Scheme"**
3. Click **"Autocreate Schemes Now"**

This creates the TrusendaCRM scheme automatically.

---

## Step 2: Select the Scheme

Top left toolbar, where it says **"No Scheme"**:

1. Click that dropdown
2. Select **"TrusendaCRM"**

---

## Step 3: Select Simulator

Next dropdown (device selector):

1. Click it
2. Select any **iPhone Simulator** (e.g., "iPhone 15 Pro")
   - **NOT** a physical device (those need code signing)

---

## Step 4: Build

Press **Cmd + B**

Or even better, press **Cmd + R** to build and run!

---

## ✅ It Should Build Now!

If Pods-TrusendaCRM scheme also appears in the list:
1. Build it first (select it, press Cmd + B)
2. Then build TrusendaCRM

---

## 🚨 If "Autocreate Schemes Now" is Grayed Out

That means schemes already exist. Try this:

1. **Product** → **Scheme** → **Manage Schemes...**
2. In the popup, find **"TrusendaCRM"**
3. Check the ✅ box to make it visible
4. Check **"Shared"** checkbox
5. Click **"Close"**
6. Now select TrusendaCRM from scheme dropdown
7. Select simulator
8. Press Cmd + R

---

## 📸 Visual Reference

**Menu Path:**
```
Product → Scheme → Autocreate Schemes Now
```

**Top Toolbar After:**
```
[▶️] [TrusendaCRM ▼] [iPhone 15 Pro ▼]
```

Then just press ▶️ or Cmd + R!

---

**This WILL work - the workspace and pods are correctly configured!**

