# 🚀 Quick Start — Data Collection SPA

**Last Updated**: October 1, 2026  
**App Status**: Refactored & Ready

---

## What Changed?

| Before | After |
|--------|-------|
| 4 navigation tabs | ✅ 3 tabs |
| Complex routing | ✅ Simplified |
| Empty home screen | ✅ Full data collection UI |
| No quick actions | ✅ Record/Upload buttons |
| Unclear purpose | ✅ Clear: Collect & Upload |

---

## Three Tabs Explained

### 1️⃣ COLLECT (Record/Upload)
**Route**: `/home`

**What you see**:
- 🎤 **Record** button — tap to record audio
- 📁 **Upload** button — tap to pick file
- 📊 **Stats** — pending uploads, storage used
- 📋 **Recent uploads** — list with progress

**Use case**: "I want to add data to the system"

---

### 2️⃣ UPLOADS (Queue & Status)
**Route**: `/sync`

**What you see**:
- ⏳ Pending uploads (waiting to go)
- ❌ Failed uploads (with error)
- ✅ Completed uploads (archived)
- 🔄 Retry buttons per file
- 🗑️ Discard buttons per file

**Use case**: "I want to check if my file uploaded"

---

### 3️⃣ SETTINGS (Profile & Preferences)
**Route**: `/profile`

**What you see**:
- 👤 User profile (name, email, phone)
- ⚙️ Sync preferences (WiFi-only, charging-only)
- 📱 App info and version
- 📤 Manual sync button

**Use case**: "I want to change my settings"

---

## File Structure

```
lib/
├── main.dart                      ← App entry point
├── core/
│   ├── config/navigation/
│   │   └── app_spa_scaffold.dart  ← ✨ UPDATED: 3-tab scaffold
│   └── router/
│       └── route_manager.dart     ← ✨ UPDATED: 3 routes only
└── features/
    ├── home/presentations/pages/
    │   └── home_page.dart         ← ✨ UPDATED: Full UI
    ├── sync/presentations/pages/
    │   └── sync_centre_page.dart  ← UNCHANGED: Upload queue
    └── profile/pages/
        └── profile_page.dart      ← UNCHANGED: Settings
```

---

## Run the App

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Expected output:
# - 3 tabs at bottom
# - Collect tab active by default
# - Record/Upload buttons visible
# - Offline status indicator
# - Recent uploads list
```

---

## Test Offline Mode

```bash
# 1. Enable airplane mode on device

# 2. Open app
# Should still work (no crash)

# 3. Tap "Record"
# Mock recording appears

# 4. Tap "Uploads" tab
# Shows file with "Pending" status

# 5. Disable airplane mode
# File uploads automatically (with mock delay)

# 6. Force quit and restart
# Everything still there ✅
```

---

## Mock Data

The home screen currently shows **mock data**:

```dart
_pendingUploads = 3         // Mock: 3 files waiting
_storageUsedMB = 245.5      // Mock: 245.5 MB used
_isOnline = true            // Mock: Always online

Recent uploads:
- Interview_Oct_01.mp3 (12.5 MB) → Uploading 65%
- Document_scan.pdf (3.2 MB)    → Uploaded ✓
- Voice_note.m4a (2.8 MB)       → Pending ⏳
```

**To use real data**:
- Connect `_loadStats()` to SyncManager
- Listen to sync queue for upload status
- Get storage stats from device storage service

---

## Key Classes

### app_spa_scaffold.dart
```dart
// 3-tab SPA with minimalist header
class AppSpaScaffold extends StatelessWidget

// Individual tab item with animations
class _SpaNavItem extends StatefulWidget
```

### home_page.dart
```dart
// Main data collection screen
class HomeScreen extends StatefulWidget

// Large action buttons
class _ActionButton extends StatelessWidget

// Storage and pending stats
class _QuickStats extends StatelessWidget

// Individual upload item with progress
class _UploadItem extends StatelessWidget
```

### route_manager.dart
```dart
// Single-page router manager
class RouterManager {
  static GoRouter get router
  static void navigateToHome()
  static void navigateToSync()
  static void navigateToProfile()
}
```

---

## Common Tasks

### Add a Stat
**File**: `lib/features/home/presentations/pages/home_page.dart`

```dart
_QuickStats(
  pendingUploads: _pendingUploads,
  storageUsedMB: _storageUsedMB,
  // ADD:
  networkSpeed: _networkSpeed,  // New stat
)
```

### Change Tab Color
**File**: `lib/core/config/navigation/app_spa_scaffold.dart`

```dart
const _primary = Color(0xFFFF6B00);   // Orange
// Change to:
const _primary = Color(0xFF0066FF);   // Blue
```

### Hide Offline Banner
**File**: `lib/features/home/presentations/pages/home_page.dart`

```dart
// Just comment out:
// if (!_isOnline) Container(...)
```

### Add a 4th Tab
**File**: `lib/core/config/navigation/app_spa_scaffold.dart`

```dart
const _tabs = [
  _TabMeta(...),  // Tab 1
  _TabMeta(...),  // Tab 2
  _TabMeta(...),  // Tab 3
  _TabMeta(...),  // NEW Tab 4
];
```

---

## Debugging

### Tab not switching?
- Check route manager for correct route path
- Verify shell branch index matches tab index (0, 1, 2)

### Scaffold looks wrong?
- Hot reload isn't enough after scaffold changes
- Use `flutter run` or restart debugger

### Home screen empty?
- Verify `HomeScreen` class exists in `home_page.dart`
- Check no build() method errors in diagnostics

### Offline indicator not showing?
- Connect to `NetworkService` in `initState()`
- `_isOnline = await _networkService.isConnected`

---

## Next Steps

### To Make It Real
1. **Connect to real API**
   - Implement actual record/upload in home screen
   - Call SyncManager to queue uploads
   - Listen to sync status updates

2. **Add error handling**
   - Handle network timeouts
   - Handle file size limits
   - Handle permission denials

3. **Add notifications**
   - Notify when upload starts/completes/fails
   - Show badges for pending items

4. **Add UI polish**
   - Loading animations
   - Empty states
   - Error states
   - Confirmation dialogs

5. **Test thoroughly**
   - Offline scenario (§7.1 from SRS)
   - Resume after crash (§7.2)
   - Large file uploads (500 MB)
   - Concurrent uploads

---

## Documentation

| Document | Purpose |
|----------|---------|
| **DATA_COLLECTION_APP_GUIDE.md** | Full architecture guide |
| **REFACTOR_SUMMARY.md** | What changed and why |
| **QUICK_START.md** | This file — get started fast |

---

## Questions?

- **How do I add a feature?** → Read `DATA_COLLECTION_APP_GUIDE.md`
- **What files changed?** → Read `REFACTOR_SUMMARY.md`
- **How do I modify colors?** → See "Common Tasks" above
- **How do I debug?** → See "Debugging" above

---

## Status Checklist

- [x] Scaffold redesigned (3 tabs)
- [x] Router simplified (3 routes)
- [x] Home screen implemented (full UI)
- [x] Navigation working
- [x] Code compiles without errors
- [x] No diagnostics/warnings
- [ ] Connected to real API
- [ ] Tested offline scenario
- [ ] Tested with real files
- [ ] Performance profiled

---

**Ready to build!** 🚀

Last updated: October 1, 2026
