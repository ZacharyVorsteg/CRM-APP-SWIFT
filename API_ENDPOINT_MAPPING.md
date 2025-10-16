# Trusenda CRM - API Endpoint Mapping
**React Web App → Swift iOS App**

This document maps each API call from the React web app to its Swift equivalent.

---

## Authentication Endpoints

### Login
**React:**
```javascript
// netlify-identity-widget handles login automatically
netlifyIdentity.on('login', (user) => { ... })
```

**Swift:**
```swift
// AuthManager.swift
func login(email: String, password: String) async throws {
    let response: AuthToken = try await client.post(
        endpoint: .login,  // POST /.netlify/identity/token
        body: LoginRequest(username: email, password: password),
        requiresAuth: false
    )
}
```

---

### Get Current User
**React:**
```javascript
// src/api.js
async me() {
    const r = await fetch('/.netlify/functions/me', { headers });
    return r.json();
}
```

**Swift:**
```swift
// AuthManager.swift
func fetchMe() async throws {
    let user: User = try await client.get(
        endpoint: .me,  // GET /.netlify/functions/me
        requiresAuth: true
    )
}
```

---

## Lead Management Endpoints

### Fetch All Leads
**React:**
```javascript
// src/api.js
async listCustomers() {
    const r = await authedFetch('/.netlify/functions/customers');
    return r.json();
}
```

**Swift:**
```swift
// LeadViewModel.swift
func fetchLeads() async {
    let response: LeadsResponse = try await client.get(
        endpoint: .customers  // GET /.netlify/functions/customers
    )
}
```

**Response Schema:**
```json
{
  "customers": [ {...}, {...} ],
  "isOverLimit": false,
  "currentCount": 3,
  "maxLeads": 10,
  "plan": "free",
  "gracePeriodDaysRemaining": null,
  "isInGracePeriod": false,
  "isBlocked": false
}
```

---

### Create Lead
**React:**
```javascript
// src/api.js
async addCustomer(payload) {
    const r = await authedFetch('/.netlify/functions/customers', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    });
    return r.json();
}
```

**Swift:**
```swift
// LeadViewModel.swift
func createLead(_ payload: LeadCreatePayload) async throws {
    let response: LeadActionResponse = try await client.post(
        endpoint: .customers,  // POST /.netlify/functions/customers
        body: payload
    )
}
```

**Request Payload:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "(555) 123-4567",
  "company": "Acme Corp",
  "budget": "50000",
  "propertyType": "Office",
  "transactionType": "Lease",
  "status": "Cold"
}
```

---

### Update Lead
**React:**
```javascript
// src/api.js
async updateCustomer(id, updates) {
    const r = await authedFetch(`/.netlify/functions/customers/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates)
    });
    return r.json();
}
```

**Swift:**
```swift
// LeadViewModel.swift
func updateLead(id: String, updates: LeadUpdatePayload) async throws {
    let response: LeadActionResponse = try await client.put(
        endpoint: .customer(id: id),  // PUT /.netlify/functions/customers/{id}
        body: updates
    )
}
```

---

### Delete Lead
**React:**
```javascript
// src/api.js
async deleteCustomer(id) {
    const r = await authedFetch(`/.netlify/functions/customers/${id}`, {
        method: 'DELETE'
    });
    return r.json();
}
```

**Swift:**
```swift
// LeadViewModel.swift
func deleteLead(id: String) async throws {
    try await client.delete(
        endpoint: .customer(id: id)  // DELETE /.netlify/functions/customers/{id}
    )
}
```

---

## Tenant & Settings Endpoints

### Get Tenant Info
**React:**
```javascript
// src/api.js
async getTenantInfo() {
    const r = await authedFetch('/.netlify/functions/tenant-info');
    return r.json();
}
```

**Swift:**
```swift
// SettingsViewModel.swift
func fetchTenantInfo() async {
    tenantInfo = try await client.get(
        endpoint: .tenantInfo  // GET /.netlify/functions/tenant-info
    )
}
```

**Response Schema:**
```json
{
  "id": 1,
  "name": "Organization Name",
  "plan": "free",
  "maxLeads": 10,
  "currentLeads": 3,
  "logoUrl": null,
  "autoTailor": false,
  "headerTheme": "blue",
  "timezone": "America/New_York"
}
```

---

### Update Branding
**React:**
```javascript
// src/api.js
async updateBranding(brandingData) {
    const r = await authedFetch('/.netlify/functions/update-branding', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(brandingData)
    });
    return r.json();
}
```

**Swift:**
```swift
// SettingsViewModel.swift
func updateBranding(logoUrl: String?, theme: String) async throws {
    let update = BrandingUpdate(logoUrl: logoUrl, autoTailor: false, headerTheme: theme)
    let _: SuccessResponse = try await client.post(
        endpoint: .updateBranding,  // POST /.netlify/functions/update-branding
        body: update
    )
}
```

---

## Stripe Checkout

### Create Checkout Session
**React:**
```javascript
// src/api.js
async createCheckoutSession(plan = 'pro') {
    const r = await authedFetch('/.netlify/functions/create-checkout-session', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ plan })
    });
    return r.json();
}
```

**Swift:**
```swift
// SettingsViewModel.swift
func createCheckoutSession() async throws -> String {
    struct CheckoutRequest: Codable { let plan = "pro" }
    let response: StripeCheckoutResponse = try await client.post(
        endpoint: .createCheckoutSession,  // POST /.netlify/functions/create-checkout-session
        body: CheckoutRequest()
    )
    return response.sessionId
}
```

---

## Follow-Up Actions

### Snooze Follow-Up
**React:**
```javascript
// src/components/LeadsOptimized.jsx
async handleSnooze(leadId, days) {
    await API.post('/.netlify/functions/lead-snooze', { 
        lead_id: leadId, 
        days 
    });
}
```

**Swift:**
```swift
// LeadViewModel.swift
func snoozeFollowUp(leadId: String, days: Int) async throws {
    struct SnoozeRequest: Codable {
        let lead_id: String
        let days: Int
    }
    try await client.post(
        endpoint: .leadSnooze,  // POST /.netlify/functions/lead-snooze
        body: SnoozeRequest(lead_id: leadId, days: days)
    )
}
```

---

### Mark Lead as Contacted
**React:**
```javascript
// src/components/LeadsOptimized.jsx
async handleMarkContacted(leadId) {
    await API.post('/.netlify/functions/lead-mark-contacted', { 
        lead_id: leadId 
    });
}
```

**Swift:**
```swift
// LeadViewModel.swift
func markContacted(leadId: String) async throws {
    struct ContactedRequest: Codable { let lead_id: String }
    try await client.post(
        endpoint: .leadMarkContacted,  // POST /.netlify/functions/lead-mark-contacted
        body: ContactedRequest(lead_id: leadId)
    )
}
```

---

## Public Forms

### Get Public Form
**React:**
```javascript
// src/components/Settings.jsx
const loadPublicForm = async () => {
    const response = await fetch('/.netlify/functions/public-form-manage', {
        headers: { 'Authorization': `Bearer ${token}` }
    });
    const data = await response.json();
    setPublicForm(data.form);
}
```

**Swift:**
```swift
// SettingsViewModel.swift
func fetchPublicForm() async {
    let response: PublicFormResponse = try await client.get(
        endpoint: .publicFormManage  // GET /.netlify/functions/public-form-manage
    )
    publicForm = response.form
}
```

---

## Account Management

### Delete Account
**React:**
```javascript
// Netlify function: netlify/functions/delete-account.js
const response = await fetch('/.netlify/functions/delete-account', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': bearer },
    body: JSON.stringify({ confirmEmail: email })
});
```

**Swift:**
```swift
// SettingsViewModel.swift
func deleteAccount(confirmEmail: String) async throws {
    struct DeleteRequest: Codable { let confirmEmail: String }
    let _: SuccessResponse = try await client.post(
        endpoint: .deleteAccount,  // POST /.netlify/functions/delete-account
        body: DeleteRequest(confirmEmail: confirmEmail)
    )
}
```

---

## Authentication Headers

### React
```javascript
// src/api.js
async function authedFetch(url, opts = {}) {
    const user = currentUser();
    const headers = { ...(opts.headers || {}) };
    if (user) {
        const token = await user.jwt();
        headers.Authorization = `Bearer ${token}`;
    }
    const response = await fetch(url, { ...opts, headers });
    return response;
}
```

### Swift
```swift
// APIClient.swift
private func addAuthHeader(to request: inout URLRequest) async throws {
    let token = try await AuthManager.shared.getValidToken()
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
}
```

---

## Error Handling

### React
```javascript
// src/api.js
if (response.status === 401 && user) {
    console.warn('Session expired');
    logout();
    window.location.reload();
    throw new Error('Session expired. Please log in again.');
}
```

### Swift
```swift
// APIClient.swift
case 401:
    // Unauthorized - token expired
    throw NetworkError.unauthorized

// In AuthManager:
catch NetworkError.unauthorized {
    logout()
    throw NetworkError.unauthorized
}
```

---

## Complete Endpoint Summary

| Endpoint | Method | React Function | Swift Function |
|----------|--------|----------------|----------------|
| `/.netlify/identity/token` | POST | netlify-identity-widget | `AuthManager.login()` |
| `/.netlify/functions/me` | GET | `API.me()` | `AuthManager.fetchMe()` |
| `/.netlify/functions/customers` | GET | `API.listCustomers()` | `LeadViewModel.fetchLeads()` |
| `/.netlify/functions/customers` | POST | `API.addCustomer()` | `LeadViewModel.createLead()` |
| `/.netlify/functions/customers/{id}` | PUT | `API.updateCustomer()` | `LeadViewModel.updateLead()` |
| `/.netlify/functions/customers/{id}` | DELETE | `API.deleteCustomer()` | `LeadViewModel.deleteLead()` |
| `/.netlify/functions/tenant-info` | GET | `API.getTenantInfo()` | `SettingsViewModel.fetchTenantInfo()` |
| `/.netlify/functions/update-branding` | POST | `API.updateBranding()` | `SettingsViewModel.updateBranding()` |
| `/.netlify/functions/create-checkout-session` | POST | `API.createCheckoutSession()` | `SettingsViewModel.createCheckoutSession()` |
| `/.netlify/functions/public-form-manage` | GET | `loadPublicForm()` | `SettingsViewModel.fetchPublicForm()` |
| `/.netlify/functions/lead-snooze` | POST | `handleSnooze()` | `LeadViewModel.snoozeFollowUp()` |
| `/.netlify/functions/lead-mark-contacted` | POST | `handleMarkContacted()` | `LeadViewModel.markContacted()` |
| `/.netlify/functions/delete-account` | POST | `deleteAccount()` | `SettingsViewModel.deleteAccount()` |

---

**All endpoints use the SAME backend** - no changes required to Netlify Functions or Neon database.

