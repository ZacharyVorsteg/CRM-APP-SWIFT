# Quick Start: Google Places Autocomplete

## 🚀 5-Minute Setup

### Step 1: Install Package (Swift Package Manager)
```
1. Xcode → File → Add Package Dependencies
2. URL: https://github.com/googlemaps/ios-places-sdk
3. Version: 9.0.0+
4. Add "GooglePlaces" library
```

### Step 2: Get API Key
1. Go to: https://console.cloud.google.com/
2. Enable **Places API**
3. Create **API Key** 
4. Restrict to:
   - **iOS apps:** `com.trusenda.TrusendaCRM`
   - **API:** Places API only

### Step 3: Add to Info.plist
Open `TrusendaCRM/Info.plist` and add:
```xml
<key>GooglePlacesAPIKey</key>
<string>YOUR_API_KEY_HERE</string>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>googlechromes</string>
    <string>comgooglemaps</string>
</array>
```

### Step 4: Build & Test
```
⌘ + Shift + K  (Clean)
⌘ + B          (Build)
⌘ + R          (Run)
```

### Step 5: Test the Feature
1. Navigate to **Properties → Add Property**
2. Tap **"Search for address..."** button
3. Type any US address
4. Select from autocomplete
5. ✅ Fields auto-fill and turn **green**

---

## 📱 Expected Behavior

### Before Address Selection
- Button shows: "Search for address..."
- **Red** icon and border
- Red asterisk (*)

### After Address Selection
- Button shows: Full address
- **Green** icon and border ✅
- Checkmarks below with details:
  - ✅ Street address
  - ✅ City, State ZIP

### Form Submission
- Only enabled when:
  - ✅ Property title filled
  - ✅ Complete address selected
  - ✅ Property details filled
  - ✅ At least 1 photo added

---

## 🐛 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| "API key not found" | Check spelling in Info.plist: `GooglePlacesAPIKey` |
| No autocomplete results | Verify Places API enabled (not just Maps) |
| REQUEST_DENIED error | Check API key restrictions match bundle ID |
| Build errors | Clean build folder (⌘ + Shift + K) |
| Fields stay red | Ensure complete address selected (needs all components) |

---

## 💰 Cost Estimate

- **Per autocomplete:** ~$0.017
- **Free tier:** $200/month = ~11,700 searches
- **Typical usage:** Most businesses stay under free tier

---

## ✅ Files Modified

**New Files:**
- `TrusendaCRM/Core/Utilities/GooglePlacesAutocomplete.swift`

**Modified Files:**
- `TrusendaCRM/Features/Properties/AddPropertyView.swift`
- `TrusendaCRM/TrusendaCRMApp.swift`

**Documentation:**
- `GOOGLE_PLACES_SETUP_GUIDE.md` (detailed guide)
- `QUICK_START_GOOGLE_PLACES.md` (this file)

---

## 🎯 Test Addresses

Try these to verify functionality:
```
1. "1600 Amphitheatre Parkway" (Mountain View, CA)
2. "1 Apple Park Way" (Cupertino, CA)
3. "350 5th Ave" (New York, NY)
4. "1600 Pennsylvania Avenue" (Washington, DC)
```

---

**Ready to ship!** 🚀

For full details, see: `GOOGLE_PLACES_SETUP_GUIDE.md`

