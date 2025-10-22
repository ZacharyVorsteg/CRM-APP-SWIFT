# Recent Activity Enhancement Plan

## Current State
Recent Activity only tracks:
- ✅ Lead Created
- ✅ Follow-Up Scheduled

## Missing Critical Events
The following events are NOT captured:
- ❌ Lead Updated (any field changes)
- ❌ Lead Status Changed (Cold → Warm → Hot → Closed)
- ❌ Lead Deleted
- ❌ Lead Contacted (mark as contacted action)
- ❌ Property Created
- ❌ Property Updated  
- ❌ Property Deleted
- ❌ Property-Lead Matches

## Architecture Decision

### Option 1: Backend Activity Log (IDEAL)
**Pros:**
- Complete, accurate history
- Captures all events automatically
- Includes deleted items
- Shows who made changes (in multi-user setups)

**Cons:**
- Requires backend changes
- Not available now
- Would need new API endpoint

### Option 2: Client-Side Inference (CURRENT APPROACH)
**Pros:**
- Works with existing API
- No backend changes needed
- Can implement immediately

**Cons:**
- Limited to current data (can't see deleted items)
- Must infer from timestamps
- Less precise (can't see individual field changes)

## Implementation Strategy

### Phase 1: Enhanced Client-Side (NOW)
Since we don't have a backend activity log endpoint, enhance client-side tracking:

1. **Lead Activities** (from LeadViewModel):
   - Created: Use `createdAt` timestamp ✅ Already done
   - Updated: Use `updatedAt` timestamp (if different from createdAt)
   - Status Changes: Track in-memory during session
   - Follow-Ups: Use `followUpOn` field ✅ Already done
   - Contacted: Track when markContacted() called

2. **Property Activities** (from PropertyViewModel):
   - Created: Use `createdAt` timestamp
   - Updated: Use `updatedAt` timestamp
   - Matches: Calculate on property creation

3. **Session-Based Tracking**:
   - Store recent actions in UserDefaults/memory
   - Include: action type, item ID, timestamp
   - Limit to current session + last 50 actions

### Phase 2: Backend Activity Log (FUTURE)
Request from backend team:
```
POST /api/activities - Get activity log
Response: [{
  id: "activity-123",
  type: "lead_created" | "lead_updated" | "property_created" | etc,
  userId: "user-123",
  itemId: "lead-456",
  itemType: "lead" | "property",
  changes: { status: { from: "Cold", to: "Warm" } },
  timestamp: "2025-10-21T10:30:00Z"
}]
```

## Implementation for Phase 1

### 1. Create ActivityTracker Singleton
```swift
class ActivityTracker {
    static let shared = ActivityTracker()
    
    func logLeadCreated(lead: Lead)
    func logLeadUpdated(lead: Lead, changes: [String: Any])
    func logLeadDeleted(leadId: String, leadName: String)
    func logStatusChange(lead: Lead, from: String, to: String)
    func logFollowUpScheduled(lead: Lead)
    func logLeadContacted(lead: Lead)
    
    func logPropertyCreated(property: Property)
    func logPropertyUpdated(property: Property)
    func logPropertyDeleted(propertyId: String, title: String)
    func logPropertyMatch(property: Property, leads: [Lead])
    
    func getRecentActivities(limit: Int) -> [ActivityItem]
}
```

### 2. Integrate with ViewModels
Add activity tracking calls in:
- LeadViewModel: createLead(), updateLead(), deleteLead(), markContacted()
- PropertyViewModel: addProperty(), updateProperty(), deleteProperty()

### 3. Enhance RecentActivityView
Display all tracked activities with:
- Appropriate icons and colors
- Smart grouping (e.g., "3 leads created today")
- Pull-to-refresh to reload from cache
- Filter by activity type

## Timeline
- ✅ Phase 1: Implement now (this session)
- ⏳ Phase 2: Request backend API (future sprint)

## Notes
- Keep last 50 activities in UserDefaults
- Clear old activities after 7 days
- Sync with backend when Phase 2 available

