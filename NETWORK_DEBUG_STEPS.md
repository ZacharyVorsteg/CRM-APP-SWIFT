# Network Timeout - Debug Steps

## The Error You're Getting

**"The request timed out" (Error -1001)**

This means the iPhone is trying to connect to `https://trusenda.com/.netlify/identity/token` but isn't getting a response.

---

## 🔍 Check These Things ON YOUR IPHONE

### 1. Is WiFi/Cellular Working?

**Test:**
1. Open Safari on iPhone
2. Go to: `https://trusenda.com`
3. **Does it load?**
   - ✅ Yes → Network is fine, continue
   - ❌ No → Fix iPhone internet connection first

### 2. Cellular Data for App

**Check:**
1. iPhone Settings
2. Cellular (or Mobile Data)
3. Scroll to "Trusenda" app
4. **Make sure it's ON** ✅

### 3. WiFi Network

**Try:**
1. Disconnect from WiFi
2. Use cellular data only
3. Try login again

**OR:**
1. Try different WiFi network
2. Some corporate WiFi blocks certain domains

---

## 🧪 Debug in Xcode

**After rebuilding, watch console:**

**You should see:**
```
🌐 Attempting login to: https://trusenda.com/.netlify/identity/token
📧 Email: zacharyvorsteg@gmail.com
📱 Network request details:
   - Method: POST
   - Content-Type: application/x-www-form-urlencoded
   - Timeout: 30s
```

**Then EITHER:**

**Success:**
```
✅ Network response received
📥 Response size: XXX bytes
📊 HTTP Status: 200
✅ Login successful!
```

**OR Error:**
```
❌ Login error (401): Invalid credentials
```

**OR Timeout:**
```
(No more messages - just timeout error)
```

---

## ✅ What I Fixed

1. **App Transport Security** - Added HTTPS config for trusenda.com
2. **Timeout** - Increased to 30 seconds
3. **Debug Logging** - See exactly what's happening
4. **Error Messages** - Better user feedback

---

## 🎯 Most Likely Issue

**Your iPhone isn't connected to internet!**

**Quick Test:**
- Open Safari on iPhone
- Google something
- If Safari works, try the app again

**If Safari doesn't work:**
- Turn WiFi off/on
- Or use cellular data
- Then try app

---

## 🔄 Try This

**In Xcode:**
1. Clean (⌘⇧K)
2. Build (⌘B)  
3. Run (⌘R)
4. **Make sure iPhone has internet** (test Safari)
5. Try logging in
6. **Watch console output**

**Send me the console log and I'll tell you exactly what's wrong!**

