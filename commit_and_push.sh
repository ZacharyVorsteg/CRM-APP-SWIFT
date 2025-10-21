#!/bin/bash
cd /Users/zachthomas/Desktop/CRM-APP-SWIFT
git add -A
git commit -m "Fix: Netlify Identity authentication - now works with production backend

- Updated login to use correct GoTrue token endpoint
- Matches web app's netlify-identity-widget behavior  
- Fixed Info.plist SceneDelegate warnings
- Suppressed harmless constraint warnings
- App now fully interoperable with React web app"
git push origin main
echo "✅ Pushed to GitHub: https://github.com/ZacharyVorsteg/CRM-APP-SWIFT"

