# Build & Test Guide - iOS App Critical Fixes

**Date:** October 19, 2025  
**Fixes Applied:** Lead editing + Public form links  
**Status:** ✅ Ready to build and test

---

## 🚀 Quick Start

### 1. Open the Project
```bash
# Navigate to the iOS project directory
cd /Users/zachthomas/Desktop/CRM-APP-SWIFT

# Open in Xcode (double-click or use command)
open TrusendaCRM.xcodeproj
```

Or simply:
- Navigate to `/Users/zachthomas/Desktop/CRM-APP-SWIFT/` in Finder
- Double-click `TrusendaCRM.xcodeproj`

---

## 🔨 Build Instructions

### Option A: Build in Xcode (Recommended)

1. **Open Xcode** → `TrusendaCRM.xcodeproj`
2. **Select Target Device:**
   - Click the device dropdown (top-left, next to "TrusendaCRM")
   - Choose: iPhone 15 Pro simulator (or your physical device)
3. **Build & Run:**
   - Press `⌘ + R` (Command + R)
   - Or click the ▶️ Play button in top-left
4. **Wait for Build:**
   - First build may take 1-2 minutes
   - Subsequent builds are faster

### Option B: Command Line Build

If you have full Xcode installed (not just Command Line Tools):

```bash
cd /Users/zachthomas/Desktop/CRM-APP-SWIFT

# Build for simulator
xcodebuild -project TrusendaCRM.xcodeproj \
  -scheme TrusendaCRM \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build

# Or build for your connected iPhone
xcodebuild -project TrusendaCRM.xcodeproj \
  -scheme TrusendaCRM \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  build
```

---

## ✅ Testing Checklist

### Phase 1: Lead Editing Tests (Critical)

#### Test 1.1: Edit Notes Field
- [ ] Open any existing lead
- [ ] Tap "Edit" (pencil icon)
- [ ] Modify the **Notes** field
- [ ] Tap "Save"
- [ ] Close lead detail
- [ ] Reopen same lead
- [ ] **VERIFY:** Notes changes are saved ✅

#### Test 1.2: Edit Multiple Fields
- [ ] Open a lead
- [ ] Tap "Edit"
- [ ] Change: Company, Industry, and Notes
- [ ] Tap "Save"
- [ ] Reopen lead
- [ ] **VERIFY:** All 3 fields updated correctly ✅

#### Test 1.3: Edit Single Field Only
- [ ] Open a lead with multiple fields filled
- [ ] Tap "Edit"
- [ ] Change ONLY the Status (e.g., Cold → Warm)
- [ ] Do NOT touch other fields
- [ ] Tap "Save"
- [ ] Reopen lead
- [ ] **VERIFY:** Status changed, other fields unchanged ✅

#### Test 1.4: Clear a Field
- [ ] Open a lead with Budget filled
- [ ] Tap "Edit"
- [ ] Clear the Budget field (make it empty)
- [ ] Tap "Save"
- [ ] **VERIFY:** Budget is now empty/cleared ✅

**Expected Results:**
- ✅ All edits save correctly
- ✅ No fields get unintentionally cleared
- ✅ No "lead not found" errors
- ✅ Changes sync with cloud web app

---

### Phase 2: Public Form Link Tests

#### Test 2.1: Copy Link
- [ ] Go to Settings → Public Form
- [ ] See your form link displayed
- [ ] Tap "Copy Link" button
- [ ] See success message: "✅ Link copied to clipboard!"
- [ ] Feel haptic feedback (vibration)
- [ ] Open Notes or Messages app
- [ ] Long-press and paste
- [ ] **VERIFY:** Full URL pasted correctly ✅

#### Test 2.2: Test Link in Safari
- [ ] Go to Settings → Public Form
- [ ] Tap "Test Link in Safari" button
- [ ] **VERIFY:** Safari opens to your form ✅
- [ ] **VERIFY:** Form displays your business/tenant name ✅
- [ ] Fill out the form (use fake data)
- [ ] Submit the form
- [ ] Return to iOS app
- [ ] Pull to refresh Leads list
- [ ] **VERIFY:** Test lead appears in your CRM ✅

#### Test 2.3: Share Link via Messages
- [ ] Go to Settings → Public Form
- [ ] Tap "Share" button
- [ ] Select "Messages"
- [ ] Send to yourself or a test contact
- [ ] Open the message on same or different device
- [ ] Tap the shared link
- [ ] **VERIFY:** Safari opens to your form ✅
- [ ] **VERIFY:** Form works correctly ✅

#### Test 2.4: Share Link via Email
- [ ] Go to Settings → Public Form
- [ ] Tap "Share" button
- [ ] Select "Mail"
- [ ] Send to yourself
- [ ] Open the email on desktop or mobile
- [ ] Click the link
- [ ] **VERIFY:** Browser opens to your form ✅
- [ ] Fill and submit the form
- [ ] **VERIFY:** Lead arrives in your CRM ✅

**Expected Results:**
- ✅ Link copies successfully
- ✅ Link opens in Safari without errors
- ✅ Form loads and displays correctly
- ✅ Form submissions create leads in CRM
- ✅ Same behavior as cloud web app

---

## 🔍 Debugging Tips

### Check Console Logs

**In Xcode:**
1. Build and run the app
2. Open Debug Console (⌘ + Shift + Y)
3. Look for these indicators:

**Lead Editing Logs:**
```
📝 updateLead() called for ID: abc-123
📦 Body: { "notes": "Updated notes" }
📨 Raw response: { "customer": { ... } }
✅ Update successful
```

**Public Form Logs:**
```
🔗 Public form URL ready: https://trusenda.com/submit/abc-xyz
📋 Copied public form link: https://trusenda.com/submit/abc-xyz
🧪 Testing public form link: https://trusenda.com/submit/abc-xyz
✅ Successfully opened form in Safari
```

### Common Issues & Solutions

#### Issue: "Lead not found" after editing
**Solution:**
- Check that you're logged in with correct account
- Verify lead exists in cloud web app
- Pull to refresh the leads list

#### Issue: Notes field appears empty after save
**Solution:**
- Check Xcode console for PUT request
- Verify response shows updated notes
- Try editing other fields (company, status)
- If all fields fail, check authentication token

#### Issue: Public form link opens but shows "Form not found"
**Solution:**
- Go to Settings → Public Form
- Verify the slug is not empty
- Use "Test Link" button to debug
- Check that form is active in database

#### Issue: Form submission doesn't create lead
**Solution:**
- Check lead count hasn't hit plan limit (10 for free)
- Verify form requires Name and Email (minimum fields)
- Check Xcode console for API errors
- Test same form from desktop browser

---

## 📊 Cloud/iOS Parity Check

After testing, verify these match between cloud web app and iOS app:

### Lead Editing Parity
| Action | Cloud Behavior | iOS Behavior | Match? |
|--------|---------------|--------------|--------|
| Edit notes only | ✅ Saves notes | ✅ Saves notes | ☑️ |
| Edit multiple fields | ✅ All save | ✅ All save | ☑️ |
| Leave field empty | ✅ Clears field | ✅ Clears field | ☑️ |
| Unchanged fields | ✅ Stay same | ✅ Stay same | ☑️ |

### Public Form Parity
| Feature | Cloud Behavior | iOS Behavior | Match? |
|---------|---------------|--------------|--------|
| Copy link | ✅ Copies URL | ✅ Copies URL | ☑️ |
| Form loads | ✅ Loads form | ✅ Loads form | ☑️ |
| Submit lead | ✅ Creates lead | ✅ Creates lead | ☑️ |
| Lead appears in CRM | ✅ Yes | ✅ Yes | ☑️ |

---

## 🎯 Success Criteria

Your fixes are working correctly if:

✅ **Lead Editing:**
- All field edits save correctly
- Notes field saves reliably
- Unchanged fields remain untouched
- No data loss or corruption
- Same behavior as cloud web app

✅ **Public Form Links:**
- Link copies to clipboard successfully
- Link opens in Safari without errors
- Form loads and displays correctly
- Form submissions create leads in CRM
- Recipients can use the link reliably

✅ **General:**
- No build errors or warnings
- App doesn't crash during testing
- UI remains responsive
- Haptic feedback works
- Success/error messages display

---

## 📱 Testing on Physical Device

**Recommended** for most realistic testing:

1. **Connect iPhone via USB**
2. **Trust Computer** (if prompted on phone)
3. **In Xcode:**
   - Select your iPhone from device dropdown
   - Ensure signing is configured (Developer account)
   - Press ⌘ + R to build and run
4. **Test as described above**

**Benefits:**
- Real-world network conditions
- Actual Safari behavior
- True haptic feedback
- Real sharing capabilities

---

## 🐛 If Something Breaks

### Lead Editing Issues

**Symptom:** Changes don't save
**Check:**
```swift
// Look for this in Lead.swift:
func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(notes, forKey: .notes)
    // ... should use encodeIfPresent for all fields
}
```

**Debug:**
- Add breakpoint in `EditLeadView.saveLead()`
- Check `updates` object before API call
- Verify only changed fields are non-nil

### Public Form Issues

**Symptom:** Link doesn't open
**Check:**
```swift
// Look for this in SettingsView.swift:
if let url = URL(string: form.fullURL) {
    print("🧪 Testing: \(form.fullURL)")
    UIApplication.shared.open(url, options: [:]) { success in
        print(success ? "✅ Success" : "❌ Failed")
    }
}
```

**Debug:**
- Use "Test Link in Safari" button
- Check console for URL validation errors
- Verify `form.slug` is not empty
- Test URL in desktop browser first

---

## 🚀 You're Ready!

Everything is set up and ready to test. The fixes have been applied and are waiting for you to build and verify.

**Next Steps:**
1. ✅ Open Xcode → Build the app (⌘ + R)
2. ✅ Run through test checklist above
3. ✅ Report any issues or confirm success

**Files Changed:**
- ✅ `TrusendaCRM/Core/Models/Lead.swift` (custom encoder)
- ✅ `TrusendaCRM/Features/Settings/SettingsView.swift` (enhanced UI)

**Documentation:**
- ✅ `IOS_CRITICAL_FIXES.md` (detailed technical explanation)
- ✅ `BUILD_AND_TEST_GUIDE.md` (this file - testing instructions)

---

Good luck with testing! 🎉

