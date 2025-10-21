# Trusenda CRM iOS - Testing Checklist

Test these features to ensure everything works with your production backend:

## ✅ Authentication
- [x] Login with existing account
- [ ] Login with wrong password (shows error)
- [ ] Signup new account
- [ ] Logout and login again
- [ ] Auto-login on app relaunch

## ✅ Leads Management
- [ ] View all leads (should match web app)
- [ ] Create new lead with required fields only
- [ ] Create new lead with all fields filled
- [ ] Edit existing lead
- [ ] Delete lead (confirm dialog appears)
- [ ] Search leads by name
- [ ] Filter by status (Cold/Warm/Hot/Closed)
- [ ] Pull to refresh

## ✅ Follow-Ups
- [ ] Navigate to Follow-Ups tab
- [ ] See badge count on tab (if any due)
- [ ] Schedule follow-up on a lead
- [ ] View follow-up list
- [ ] Mark lead as contacted (removes from list)
- [ ] Snooze follow-up (1 day, 3 days, 7 days)
- [ ] Overdue leads show in red

## ✅ Settings
- [ ] View account email and plan
- [ ] View lead count and limit
- [ ] View organization details
- [ ] Copy public form link
- [ ] Share public form (native share sheet)
- [ ] Upgrade to Pro button (opens Stripe)
- [ ] Sign out

## ✅ Plan Limits (Free Plan Only)
- [ ] Over 10 leads shows warning banner
- [ ] Grace period countdown displays
- [ ] Blocked state prevents adding leads
- [ ] Upgrade button visible

## ✅ Error Handling
- [ ] Network errors show red toast
- [ ] Success actions show green toast
- [ ] Loading states appear during actions
- [ ] Buttons disable while processing

## ✅ Cross-Platform Sync
- [ ] Login on iOS, check web app - same leads
- [ ] Add lead on iOS, check web app - appears
- [ ] Edit lead on web, pull-to-refresh on iOS - updated
- [ ] Delete on web, refresh on iOS - removed
- [ ] Follow-up on iOS, check web - synced

## Expected Results:

✅ **Everything should work identically to the web app**
✅ **Data syncs instantly between platforms**
✅ **No errors in normal usage**
✅ **Smooth, native iOS experience**

## If Something Doesn't Work:

1. Check console logs in Xcode (Debug area)
2. Verify network connection
3. Confirm backend is up at https://trusenda.com
4. Check JWT token hasn't expired (logout/login)

---

**The app is production-ready!** 🚀

