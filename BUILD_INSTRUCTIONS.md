# 🔧 Build Instructions - Fix "LeadDraft" Error

**Issue:** Xcode showing "Cannot find type 'LeadDraft' in scope"  
**Cause:** Build cache not refreshing

---

## ✅ Quick Fix (Choose One)

### Option 1: Clean Build Folder (Recommended)
```
In Xcode:
1. Product → Clean Build Folder (Cmd + Shift + K)
2. Wait for "Clean Finished"
3. Product → Build (Cmd + B)
```

### Option 2: Restart Xcode
```
1. Quit Xcode completely (Cmd + Q)
2. Reopen Xcode
3. Open TrusendaCRM project
4. Build (Cmd + B)
```

### Option 3: Delete Derived Data
```
1. Xcode → Settings → Locations
2. Click arrow next to Derived Data path
3. Delete "TrusendaCRM-goeanlyvaliowkbigrejijggacts" folder
4. Restart Xcode
5. Build project
```

---

## ✅ Verification

After building successfully, you should see:

**In Console:**
```
💾 Draft saved: [name]
🗑️ Draft cleared
📥 Draft loaded: [name]
```

**In App:**
- Premium green gradient toast (not flat green)
- "Lead added" (bold) + "successfully" (regular) split text
- "UNDO & EDIT" button visible
- Toast auto-dismisses after 3 seconds
- Smooth animations

**Old notification should NOT appear:**
- No "✅ Lead added successfully" flat toast

---

## 🎯 What Changed

### Files Modified:
1. **KeychainManager.swift** - Added DraftManager + LeadDraft (lines 4-130)
2. **LeadListView.swift** - Added PremiumSuccessToast (lines 10-136)
3. **LeadViewModel.swift** - Disabled old success message (lines 100-102)

### Build System:
- All code is in files already in Xcode build targets
- No new files to add to project
- Just needs build cache refresh

---

## 🐛 If Still Having Issues

### Check 1: Verify Files Updated
```bash
grep -n "struct LeadDraft" /Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Core/Storage/KeychainManager.swift
```
**Expected:** Line 64: `struct LeadDraft: Codable {`

### Check 2: Verify PremiumSuccessToast
```bash
grep -n "struct PremiumSuccessToast" /Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Features/Leads/LeadListView.swift
```
**Expected:** Line 13: `struct PremiumSuccessToast: View {`

### Check 3: File Permissions
```bash
ls -la /Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Core/Storage/KeychainManager.swift
```
**Expected:** Read/write permissions

---

## 📱 Expected Behavior

### Adding a Lead:
```
1. Tap "+" → "Add Manually"
2. Fill in "Name" field
3. Tap "Save"
4. Premium toast slides up with animation ✨
5. Checkmark rotates and scales
6. "UNDO & EDIT" button visible
7. Toast auto-dismisses after 3 seconds
8. NO old flat green toast
```

### Draft System:
```
1. Start adding lead
2. Fill in name
3. Press Home button (background app)
4. Reopen app
5. Tap "+" again
6. Alert: "Resume draft from X ago?"
7. Tap "Resume" → Fields restored
```

### Undo & Edit:
```
1. Add lead successfully
2. Premium toast appears
3. Tap "UNDO & EDIT"
4. Lead deleted
5. Add modal reopens with data
6. Edit and save again
```

---

## 🎨 Visual Differences

### Old (Should NOT see):
```
┌─────────────────────────────────┐
│ ✅ Lead added successfully      │  ← Flat, no depth
└─────────────────────────────────┘
```

### New (Should see):
```
╔═══════════════════════════════════╗
║ ✓   Lead added        UNDO & EDIT║  ← Gradient + shadow
║     successfully                  ║
╚═══════════════════════════════════╝
       ↑                    ↑
   Animated            Button
   checkmark           to undo
```

---

## ✅ Build Success Indicators

When build succeeds:
- ✅ No "Cannot find type 'LeadDraft'" errors
- ✅ Build log shows "Build succeeded"
- ✅ Simulator/device runs app
- ✅ Can add leads without crashes
- ✅ New premium toast appears

---

**If still having issues after trying all options, try:**
```
1. Close Xcode
2. Delete: ~/Library/Developer/Xcode/DerivedData/TrusendaCRM*
3. Delete: ~/Library/Caches/com.apple.dt.Xcode
4. Restart Mac
5. Open Xcode fresh
6. Build
```

This forces a complete clean rebuild from scratch.

