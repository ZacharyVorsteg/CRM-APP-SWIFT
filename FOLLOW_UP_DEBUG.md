# Follow-Up Logic Debug Guide

## To Debug Why Follow-Ups Aren't Showing:

### Step 1: Check Console Logs

When you run the app, look for these log messages in Xcode console:

```
📅 Lead follow-up check: followUpOn=2025-10-16, followUpDay=..., today=..., isDue=true/false
```

This will show you:
- Which leads have follow-up dates
- What dates they're comparing
- Whether the logic thinks they're due

### Step 2: Verify Data from Backend

Check if `followUpOn` field is coming from backend:
- Look for: `followUpOn=2025-10-16` in logs
- Should be in `YYYY-MM-DD` format

### Step 3: Check Follow-Ups Tab

Navigate to Follow-Ups tab and check console for:
```
📊 Follow-Ups tab: Found X due leads out of Y total
```

### Common Issues:

1. **Date format mismatch**
   - Backend sends: "2025-10-16"
   - iOS expects: "YYYY-MM-DD"
   - ✅ Now fixed to parse correctly

2. **Timezone issues**
   - Web app uses local timezone
   - iOS was using UTC
   - ✅ Now both use same logic

3. **Missing needsAttention flag**
   - iOS now checks date directly (doesn't rely on flag)
   - ✅ Matches web app logic

## What I Fixed:

1. ✅ Date parsing for `followUpOn` (was using wrong formatter)
2. ✅ Added debug logging to see what's happening
3. ✅ Simplified date comparison logic
4. ✅ Matches web app exactly

## Expected Result:

After rebuild, Follow-Ups tab should show:
- Lead "Zachary" with follow-up due today
- Badge on Follow-Ups tab showing "1"
- Same as web app

If it still doesn't work, check console logs and let me know what you see!

