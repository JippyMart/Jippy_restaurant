# 🔄 App Update System Setup Guide

## 🎯 Overview
Your restaurant app now has a complete app update system that automatically checks for updates and prompts users to update when new versions are available.

## 📱 Current App Version
- **Version**: `2.2.3+12`
- **Package**: `com.jippymart.restaurant`

## 🔥 Firebase Setup

### Step 1: Create Firestore Collection and Documents

Go to your **Firebase Console** → **Firestore Database** and create:

**Collection**: `app_settings`

Then create **3 separate documents** for your apps:

1. **Document ID**: `restaurant` (for Restaurant/Merchant app)
2. **Document ID**: `customer` (for Customer app)  
3. **Document ID**: `driver` (for Driver app)

### Step 2: Add Version Data

Add the following fields to the **`restaurant`** document:

```json
{
  "latest_version": "2.2.4",
  "force_update": false,
  "update_url": "https://play.google.com/store/apps/details?id=com.jippymart.restaurant",
  "android_version": "2.2.4",
  "ios_version": "2.2.4",
  "android_build": "13",
  "ios_build": "13",
  "min_required_version": "2.0.0",
  "update_message": "New features and bug fixes available! Update now for the best experience.",
  "last_updated": "2024-01-15T10:30:00Z"
}
```

### Step 3: Setup for Other Apps (Optional)

For **Customer App** (`customer` document):
```json
{
  "latest_version": "2.2.4",
  "force_update": false,
  "update_url": "https://play.google.com/store/apps/details?id=com.jippymart.customer",
  "android_version": "2.2.4",
  "ios_version": "2.2.4",
  "android_build": "13",
  "ios_build": "13",
  "min_required_version": "2.0.0",
  "update_message": "New features and bug fixes available!",
  "last_updated": "2024-01-15T10:30:00Z"
}
```

For **Driver App** (`driver` document):
```json
{
  "latest_version": "2.2.4",
  "force_update": false,
  "update_url": "https://play.google.com/store/apps/details?id=com.jippymart.driver",
  "android_version": "2.2.4",
  "ios_version": "2.2.4",
  "android_build": "13",
  "ios_build": "13",
  "min_required_version": "2.0.0",
  "update_message": "New features and bug fixes available!",
  "last_updated": "2024-01-15T10:30:00Z"
}
```

## 📋 Field Descriptions

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `latest_version` | String | Latest version available | "2.2.4" |
| `force_update` | Boolean | If true, user cannot dismiss dialog | false |
| `update_url` | String | Play Store/App Store link | "https://play.google.com/store/apps/details?id=com.jippymart.restaurant" |
| `android_version` | String | Latest Android version | "2.2.4" |
| `ios_version` | String | Latest iOS version | "2.2.4" |
| `android_build` | String | Android build number | "13" |
| `ios_build` | String | iOS build number | "13" |
| `min_required_version` | String | Minimum version required | "2.0.0" |
| `update_message` | String | Custom message for users | "New features and bug fixes available!" |
| `last_updated` | Timestamp | When this was last updated | "2024-01-15T10:30:00Z" |

## 🚀 How It Works

### 1. **Automatic Check**
- App checks for updates when it starts (splash screen)
- Real-time listener monitors Firestore for changes
- Compares current version with latest version

### 2. **Update Dialog**
- Shows beautiful update dialog if update is available
- Different behavior for force vs optional updates
- Direct link to Play Store/App Store

### 3. **Manual Check**
- Users can manually check for updates from Profile screen
- "Check for Updates" button in profile section

## 🎨 Features

### ✅ **Automatic Detection**
- Compares semantic versions (2.2.3 vs 2.2.4)
- Handles build numbers correctly
- Real-time updates via Firestore listener

### ✅ **Smart Update Logic**
- **Optional Update**: User can dismiss dialog
- **Force Update**: User cannot dismiss, must update
- **Minimum Version**: Blocks app if version is too old

### ✅ **Beautiful UI**
- Matches your app's design theme
- Dark/light mode support
- Smooth animations and transitions

### ✅ **Error Handling**
- Graceful fallbacks if Firestore is unavailable
- Network error handling
- Version comparison error handling

## 🧪 Testing

### Test 1: Optional Update
```json
{
  "latest_version": "2.2.4",
  "force_update": false,
  "update_message": "Optional update available with new features!"
}
```

### Test 2: Force Update
```json
{
  "latest_version": "2.3.0",
  "force_update": true,
  "update_message": "Critical security update required!"
}
```

### Test 3: Minimum Version
```json
{
  "latest_version": "2.2.4",
  "force_update": false,
  "min_required_version": "2.2.0",
  "update_message": "Please update to continue using the app."
}
```

## 📊 Monitoring

### Check Update Status
```dart
// In your code
final appUpdateController = Get.find<AppUpdateController>();
print('Update Available: ${appUpdateController.getUpdateAvailable()}');
print('Latest Version: ${appUpdateController.getLatestVersion()}');
print('Update Message: ${appUpdateController.getUpdateMessage()}');
```

### Console Logs
The system logs detailed information:
```
📱 Current App Version: 2.2.3+12
🔍 Checking for updates...
📱 Current: 2.2.3
🚀 Latest: 2.2.4
⚡ Force Update: false
✅ Update available! Force: false
```

## 🔧 Customization

### Update Dialog Styling
Edit `lib/widget/app_update_dialog.dart` to customize:
- Colors and themes
- Button styles
- Icons and animations
- Text content

### Update Logic
Edit `lib/controller/app_update_controller.dart` to modify:
- Version comparison logic
- Update check frequency
- Error handling behavior

### Constants
Edit `lib/constant/constant.dart` to change:
- Collection names
- Default URLs
- App identifiers

## 🚨 Important Notes

### 1. **Version Format**
- Use semantic versioning: `major.minor.patch`
- Example: `2.2.4`, `3.0.0`, `1.1.1`

### 2. **Build Numbers**
- Android: `versionCode` in `build.gradle`
- iOS: `CFBundleVersion` in `Info.plist`
- Current: `12`

### 3. **Testing Strategy**
- Test with higher version numbers than current
- Test both force and optional updates
- Test minimum version requirements

### 4. **Rollback Plan**
- You can rollback by setting `latest_version` to older version
- Monitor user feedback before forcing updates
- Gradual rollout by updating Firestore gradually

## 🔒 Security Rules

Add to your Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /app_settings/{document} {
      allow read: if true;  // Anyone can read app settings
      allow write: if false; // Only admin can write (via Firebase Console)
    }
  }
}
```

## 📈 Analytics (Optional)

Track update effectiveness by adding analytics:

```dart
// Track when update dialog is shown
analytics.logEvent(name: 'app_update_dialog_shown', parameters: {
  'current_version': currentVersion,
  'latest_version': latestVersion,
  'force_update': isForceUpdate,
});

// Track when user clicks update
analytics.logEvent(name: 'app_update_clicked', parameters: {
  'current_version': currentVersion,
  'latest_version': latestVersion,
});
```

## 🛠️ Dynamic Document Generation

### Option 1: Web-Based Generator (Recommended)
1. Open `scripts/app_settings_generator.html` in your browser
2. Fill in the form with your version details
3. Click "Generate Settings" to create the JSON
4. Copy the JSON and paste it into your Firebase document

### Option 2: Command Line Tool
1. Update Firebase configuration in `scripts/create_app_settings.dart`
2. Run the script with your parameters:
   ```bash
   # Create settings for all apps
   dart scripts/create_app_settings.dart create-all 2.2.4 13 13 false 2.0.0 "New features available!"
   
   # Create settings for restaurant app only
   dart scripts/create_app_settings.dart create restaurant 2.2.4 13 13 false 2.0.0 "Restaurant app update!"
   
   # Update existing settings
   dart scripts/create_app_settings.dart update restaurant 2.2.5
   
   # List all current settings
   dart scripts/create_app_settings.dart list
   ```

## 🎯 Next Steps

1. **Use the web generator** to create your initial Firebase documents
2. **Set up Firestore documents** with the generated JSON
3. **Test the system** with different version scenarios
4. **Deploy to production** and monitor user behavior
5. **Update version data** when you release new versions using the generators

## 🆘 Troubleshooting

### Issue: Update dialog not showing
- Check Firestore document exists and has correct data
- Verify version comparison logic
- Check console logs for errors

### Issue: Force update not working
- Ensure `force_update` is set to `true`
- Check `min_required_version` logic
- Verify dialog barrier dismissible setting

### Issue: Update URL not working
- Verify URL is correct and accessible
- Check `url_launcher` permissions
- Test URL in browser first

---

## 🎉 You're All Set!

Your restaurant app now has a professional app update system that will:
- ✅ Automatically check for updates
- ✅ Show beautiful update dialogs
- ✅ Handle force and optional updates
- ✅ Provide manual update checking
- ✅ Work seamlessly with your existing app

**Happy updating! 🚀**
