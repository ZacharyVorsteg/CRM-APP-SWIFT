# 🎯 Quick Fix: Build for Simulator

## The Issue
You're building for **iPhone 16 Pro (Device)** which requires:
- Code signing certificates
- Provisioning profiles
- Paid Apple Developer account

## ✅ Solution: Use Simulator

### In Xcode

1. **Click the device selector** (top toolbar, shows "iPhone 16 Pro")
2. **Select**: Any iPhone Simulator (e.g., "iPhone 15 Pro")
3. **Press Cmd + B** to build

**This will work!** Simulators don't need code signing.

---

## 📋 Step-by-Step Visual Guide

**Top of Xcode:**
```
[▶️] [TrusendaCRM ▼] [iPhone 16 Pro (492CF891...) ▼]
                                  ^
                           Click here, select simulator
```

**Choose any simulator:**
- iPhone 15 Pro
- iPhone 15
- iPhone 14 Pro
- Any iOS simulator

Then press **Cmd + B** or **Cmd + R**

---

## 🎉 Expected Result

```
✓ Build Pods
✓ Build TrusendaCRM  
✓ Build Succeeded
```

Then you can run in simulator and test Auth0 login!

