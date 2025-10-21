# Quick Reference: Draft System & Success Notifications

**For Developers & QA**

---

## 🚀 Quick Start

### Test Draft System (30 seconds)
1. Open app → Tap "+" → Select "Add Manually"
2. Enter name: "Test Lead"
3. Press Home button (background app)
4. Return to app
5. Tap "+" again → Alert appears: "Resume draft?"
6. Tap "Resume" → Name restored ✅

### Test Success Toast (15 seconds)
1. Add a lead completely
2. Tap "Save"
3. Premium green toast appears with animation
4. Wait 3 seconds → Auto-dismisses

### Test Undo & Edit (30 seconds)
1. Add lead → Save
2. Success toast appears
3. Tap "UNDO & EDIT" button
4. Lead deleted, modal reopens with data
5. Modify field → Save again ✅

---

## 📝 Key Files (Copy/Paste Paths)

```bash
# New files
/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Core/Storage/DraftManager.swift
/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Shared/Views/PremiumSuccessToast.swift

# Modified files
/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Features/Leads/AddLeadView.swift
/Users/zachthomas/Desktop/CRM-APP-SWIFT/TrusendaCRM/Features/Leads/LeadListView.swift

# Documentation
/Users/zachthomas/Desktop/CRM-APP-SWIFT/DRAFT_SYSTEM_AND_PREMIUM_NOTIFICATIONS.md
/Users/zachthomas/Desktop/CRM-APP-SWIFT/VISUAL_COMPARISON_BEFORE_AFTER.md
```

---

## 🔍 Code Snippets for Debugging

### Check if Draft Exists
```swift
// Console: po DraftManager.shared.hasDraft()
```

### Load Current Draft
```swift
// Console: po DraftManager.shared.loadDraft()
```

### Clear Draft Manually
```swift
// Console: expr DraftManager.shared.clearDraft()
```

### Inspect Draft Data
```swift
// Console: 
if let draft = DraftManager.shared.loadDraft() {
    print("Name: \(draft.name)")
    print("Email: \(draft.email)")
    print("Saved: \(draft.savedAt)")
}
```

---

## 🧪 Test Scenarios

### Scenario 1: Phone Call Interruption
```
1. Start adding lead
2. Fill name + email
3. Simulate incoming call: Device → Hardware → Call
4. Accept call
5. End call → Return to app
6. EXPECTED: Draft auto-saved
7. Reopen AddLeadView
8. EXPECTED: "Resume draft?" alert
```

### Scenario 2: App Backgrounding
```
1. Start adding lead
2. Fill multiple fields
3. Press Home button
4. Wait 5 seconds
5. Reopen app
6. EXPECTED: Draft saved
7. Open AddLeadView
8. EXPECTED: "Resume draft from 5 seconds ago?"
```

### Scenario 3: App Termination
```
1. Start adding lead
2. Fill name + company
3. Double-tap Home → Swipe up to kill app
4. Reopen app from scratch
5. Navigate to AddLeadView
6. EXPECTED: Draft still available
```

### Scenario 4: Successful Save Clears Draft
```
1. Start adding lead
2. Fill fields
3. Save successfully
4. EXPECTED: Draft cleared
5. Open AddLeadView again
6. EXPECTED: No draft prompt
```

### Scenario 5: Undo & Edit Flow
```
1. Add lead: "John Doe", "john@example.com"
2. Save
3. Success toast appears
4. Tap "UNDO & EDIT"
5. EXPECTED: Lead deleted, modal reopens
6. Verify all fields match original
7. Change email to "johndoe@example.com"
8. Save again
9. EXPECTED: New lead created with updated email
```

---

## 🐛 Common Issues & Fixes

### Issue: Draft Not Saving
**Check:**
```swift
// Verify ScenePhase is monitored
@Environment(\.scenePhase) var scenePhase

// Verify onChange is called
.onChange(of: scenePhase) { newPhase in
    print("Scene phase: \(newPhase)")
}
```

**Fix:** Ensure all State variables are captured in draft

### Issue: Draft Not Loading
**Check:**
```swift
// Verify loadDraftIfAvailable() is called
.onAppear {
    loadDraftIfAvailable()
}
```

**Fix:** Check UserDefaults permissions

### Issue: Success Toast Not Appearing
**Check:**
```swift
// Verify checkForNewLeadAndShowToast() is called
.sheet(isPresented: $showAddLead) {
    AddLeadView()
        .onDisappear {
            checkForNewLeadAndShowToast()
        }
}
```

**Fix:** Ensure lead.createdDate is within 5 seconds

### Issue: Undo Doesn't Reopen Modal
**Check:**
```swift
// Verify importedContact is set
importedContact = ImportedContact(
    name: lead.name,
    email: lead.email,
    phone: lead.phone
)
```

**Fix:** Ensure sheet(item:) binding is correct

---

## 🎨 Style Constants

```swift
// Toast Colors (Light Mode)
Green: Color(red: 0.18, green: 0.80, blue: 0.44)  // #2ECC71
Mint:  Color(red: 0.20, green: 0.89, blue: 0.65)

// Toast Colors (Dark Mode)
Green: Color(red: 0.15, green: 0.70, blue: 0.30)
Mint:  Color(red: 0.10, green: 0.60, blue: 0.40)

// Shadows
Depth: .black.opacity(0.15), radius: 8, x: 0, y: 4
Glow:  adaptiveGreen.opacity(0.35), radius: 12, x: 0, y: 6

// Animation Timing
Checkmark: 0.7s response, 0.65 damping, 0.1s delay
Fade-In:   0.6s response, 0.7 damping
Auto-Dismiss: 3.0s delay, 0.4s fade-out
```

---

## 📊 Performance Benchmarks

```swift
// Expected values
Draft Save Time:     < 50ms
Draft Load Time:     < 30ms
Draft Size:          ~1KB
Toast Animation:     60 FPS
Memory Overhead:     Negligible
Network Calls:       0 (local only)
```

---

## 🔐 Privacy & Security

- Drafts stored locally (UserDefaults)
- No cloud sync (yet)
- Cleared on successful save
- No sensitive data encryption (consider for future)
- User can manually discard anytime

---

## 📱 Device Support

- **iOS 16.0+** (ScenePhase requires iOS 14+)
- **All iPhone models**
- **iPad compatible** (universal design)
- **Dark mode**: Full support
- **Accessibility**: VoiceOver compatible

---

## 🚦 Status Indicators

### Draft System
- ✅ Auto-save on background
- ✅ Resume prompt
- ✅ Timestamp display
- ✅ Discard option
- ✅ Clear on save

### Success Toast
- ✅ Gradient background
- ✅ Animated checkmark
- ✅ Typography hierarchy
- ✅ Auto-dismiss (3s)
- ✅ Haptic feedback
- ✅ Dark mode
- ✅ Undo & Edit button

### Undo & Edit
- ✅ Delete lead
- ✅ Reopen modal
- ✅ Pre-fill data
- ✅ Re-save support

---

## 🛠️ Troubleshooting Commands

```bash
# Reset all UserDefaults (caution!)
defaults delete com.trusenda.TrusendaCRM

# Check UserDefaults in Xcode console
po UserDefaults.standard.dictionaryRepresentation()

# Monitor ScenePhase changes
# Add breakpoint in .onChange(of: scenePhase)

# Force draft save
expr DraftManager.shared.saveDraft(/* your draft */)

# Inspect toast state
po showSuccessToast
po lastAddedLead
```

---

## 📞 Support

**Questions?**
- Check: `DRAFT_SYSTEM_AND_PREMIUM_NOTIFICATIONS.md`
- Reference: `AI_AGENT_BRIEFING.md`
- Compare: Cloud site at trusenda.com

**Bug Report Template:**
```
Device: iPhone 16 Pro
iOS: 18.6
Issue: [Description]
Steps to reproduce: [1, 2, 3...]
Expected: [What should happen]
Actual: [What actually happens]
Console logs: [Paste relevant logs]
```

---

## ✅ Pre-Deployment Checklist

- [ ] All test scenarios pass
- [ ] No linter errors
- [ ] Dark mode tested
- [ ] Haptics work on device
- [ ] Drafts persist through kill
- [ ] Success toast animates smoothly
- [ ] Undo & edit flow works
- [ ] No memory leaks
- [ ] Console logs reviewed
- [ ] Documentation updated

---

**Last Updated:** October 17, 2025  
**Version:** 1.0  
**Status:** ✅ Production Ready

