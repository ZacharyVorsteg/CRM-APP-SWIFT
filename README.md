# Trusenda CRM - Native iOS App

A native Swift iOS app for Trusenda CRM, providing full-featured real estate lead management on iPhone and iPad.

## 🎯 Project Overview

This is a **functionally-identical** native iOS port of the Trusenda CRM React web app. It uses the **same backend** (Netlify Functions + Neon PostgreSQL) with zero backend modifications required.

- **Backend**: Netlify Serverless Functions + Neon PostgreSQL (unchanged)
- **Authentication**: Netlify Identity JWT tokens (compatible with web app)
- **Frontend**: 100% Swift + SwiftUI
- **Deployment Target**: iOS 16.0+
- **Architecture**: MVVM with Combine

---

## 📱 Features

### ✅ Complete Feature Parity
- Lead management (CRUD operations)
- Follow-up scheduling & reminders
- Status tracking (Cold → Warm → Hot → Closed)
- Timeline auto-progression
- Search & filtering
- Plan limits & grace periods
- Stripe Pro upgrade
- Public form management
- Settings & account management

### 🆕 iOS-Specific Enhancements
- Native SwiftUI interface
- Pull-to-refresh
- Swipe actions for quick edits
- System date picker
- Native share sheet
- Keychain secure storage (more secure than web localStorage)

---

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+ deployment target
- Swift 5.9+
- Active Trusenda backend (already deployed at https://trusenda.com)

### Installation

1. **Clone the repository**
   ```bash
   cd /Users/zachthomas/Desktop/CRM-APP-SWIFT
   ```

2. **Open in Xcode**
   ```bash
   open TrusendaCRM.xcodeproj
   ```

3. **Configure Bundle Identifier**
   - Open project settings in Xcode
   - Change bundle identifier to: `com.trusenda.crm`
   - Select your development team

4. **Build and Run**
   - Select target device (iPhone or iPad)
   - Press `Cmd + R` to build and run

---

## 📂 Project Structure

```
TrusendaCRM/
├── TrusendaCRMApp.swift          # App entry point
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift       # HTTP client
│   │   ├── Endpoints.swift       # API routes
│   │   ├── NetworkError.swift    # Error handling
│   │   └── AuthManager.swift     # JWT auth
│   ├── Models/
│   │   ├── Lead.swift
│   │   ├── User.swift
│   │   ├── TenantInfo.swift
│   │   └── APIResponses.swift
│   ├── Storage/
│   │   └── KeychainManager.swift # Secure token storage
│   └── Utilities/
│       ├── PhoneFormatter.swift
│       ├── Validation.swift
│       └── DateFormatter+Extensions.swift
├── Features/
│   ├── Authentication/
│   │   ├── LoginView.swift
│   │   └── AuthViewModel.swift
│   ├── Leads/
│   │   ├── LeadListView.swift
│   │   ├── LeadDetailView.swift
│   │   ├── AddLeadView.swift
│   │   └── LeadViewModel.swift
│   ├── FollowUps/
│   │   └── FollowUpListView.swift
│   └── Settings/
│       ├── SettingsView.swift
│       └── SettingsViewModel.swift
└── Resources/
    └── Assets.xcassets
```

---

## 🔐 Authentication

The iOS app uses **Netlify Identity JWT tokens**, maintaining full compatibility with the web app:

1. User enters email/password
2. App calls `POST /.netlify/identity/token`
3. Receives JWT access token + refresh token
4. Stores tokens securely in iOS Keychain
5. Includes `Authorization: Bearer {token}` in all API requests
6. Auto-refreshes token when expired

### Token Storage
- **Web app**: localStorage (browser)
- **iOS app**: Keychain (more secure, persists across app deletions)

---

## 🌐 API Integration

All API calls use the **production Netlify Functions** at `https://trusenda.com/.netlify/functions/`:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/me` | GET | Get current user info |
| `/customers` | GET | Fetch all leads |
| `/customers` | POST | Create new lead |
| `/customers/{id}` | PUT | Update lead |
| `/customers/{id}` | DELETE | Delete lead |
| `/tenant-info` | GET | Get org details |
| `/update-branding` | POST | Update logo/theme |
| `/create-checkout-session` | POST | Stripe upgrade |
| `/lead-snooze` | POST | Snooze follow-up |
| `/lead-mark-contacted` | POST | Clear follow-up |
| `/delete-account` | POST | Delete account |

See [API_ENDPOINT_MAPPING.md](../API_ENDPOINT_MAPPING.md) for complete mapping.

---

## 🧪 Testing

### Manual Test Checklist

**Authentication:**
- [ ] Login with valid credentials
- [ ] Login with invalid credentials shows error
- [ ] Token refresh after 1 hour
- [ ] Logout clears Keychain
- [ ] Auto-login on app launch (if token valid)

**Leads:**
- [ ] Fetch leads on launch
- [ ] Create new lead
- [ ] Update existing lead
- [ ] Delete lead
- [ ] Search leads
- [ ] Filter by status
- [ ] Pull-to-refresh

**Follow-Ups:**
- [ ] Schedule follow-up (future date)
- [ ] Badge shows count
- [ ] Snooze follow-up (1d/3d/7d)
- [ ] Mark as contacted

**Settings:**
- [ ] View plan details
- [ ] Upgrade to Pro (opens Stripe)
- [ ] View public form link
- [ ] Copy/share form
- [ ] Delete account

**Plan Limits:**
- [ ] Over limit banner (free plan with >10 leads)
- [ ] Grace period countdown
- [ ] Blocked state (can't add leads)

---

## 🚢 Deployment

### TestFlight (Internal Testing)

1. **Archive the app**
   ```
   Xcode → Product → Archive
   ```

2. **Upload to App Store Connect**
   - Select archive in Organizer
   - Click "Distribute App"
   - Select "App Store Connect"
   - Upload

3. **Add internal testers**
   - Go to App Store Connect
   - TestFlight → Internal Testing
   - Add testers via email

### App Store (Production)

1. **Prepare marketing assets**
   - App icon (1024x1024)
   - Screenshots (iPhone 6.7", 6.5", iPad Pro 12.9")
   - App description
   - Keywords: "CRM, real estate, leads, property, commercial"

2. **Submit for review**
   - Complete App Store Connect metadata
   - Submit for review
   - Approval typically takes 1-3 days

---

## 📊 Architecture Decisions

### Why MVVM?
- Clean separation of concerns
- Testable business logic
- Matches SwiftUI's declarative patterns

### Why Keychain over UserDefaults?
- Keychain is encrypted by default
- Survives app deletion (secure token persistence)
- Required for sensitive data (JWT tokens)

### Why async/await over Combine?
- Cleaner syntax for async operations
- Better error handling
- Modern Swift concurrency

---

## 🐛 Known Issues & Limitations

1. **Netlify Identity SDK**: No official Swift SDK, using REST API directly
2. **Stripe Checkout**: Opens in Safari (not native payment sheet)
3. **CSV Import**: Not yet implemented (web-only for now)
4. **Offline Mode**: Not implemented (requires local CoreData cache)

---

## 🔮 Future Enhancements

- [ ] Push notifications for follow-up reminders
- [ ] Home screen widget (lead count + follow-ups)
- [ ] Biometric authentication (Face ID / Touch ID)
- [ ] CSV import/export
- [ ] Offline mode with CoreData
- [ ] iPad multi-column layout
- [ ] Dark mode support
- [ ] Siri shortcuts integration

---

## 📚 Documentation

- [Technical Specification](../SWIFT_MIGRATION_SPEC.md) - Complete migration spec
- [API Mapping](../API_ENDPOINT_MAPPING.md) - React → Swift endpoint mapping
- [React Source](../src/) - Original React app for reference

---

## 🤝 Contributing

This is a private project. For questions or issues, contact:
- **Email**: support@trusenda.com
- **GitHub**: [CRM-APP-SWIFT](https://github.com/yourusername/CRM-APP-SWIFT)

---

## 📄 License

Proprietary - Trusenda Inc.

---

## 🎉 Success Criteria

The iOS app is considered **feature-complete** when:

✅ All CRUD operations work  
✅ Authentication is stable  
✅ Follow-ups sync correctly  
✅ Plan limits enforced  
✅ Stripe checkout works  
✅ No crashes in normal usage  
✅ Passes App Store review  

---

**Built with ❤️ using Swift & SwiftUI**

