# URL Branch ID Implementation for Web/PWA

## Overview
This implementation extracts the `branch_id` parameter from the URL when the app is accessed via web or as a Progressive Web App (PWA), and saves it to local storage for persistent use.

## How It Works

### 1. URL Parameter Extraction
When a user scans a QR code, they'll be redirected to a URL like:
```
https://yourdomain.com/?branch_id=12345
```

The app automatically extracts the `branch_id` parameter and saves it to SharedPreferences.

### 2. Platform-Specific Implementation
The implementation uses conditional imports to handle different platforms:

- **Web**: Uses `dart:html` to access `window.location.href` and extract query parameters
- **Mobile**: Returns null (QR codes would typically open web version or use deep links)
- **Stub**: Fallback implementation

### 3. Files Added

#### Core Utility Files
- `lib/utils/url_utils.dart` - Main utility class with platform detection
- `lib/utils/url_utils_web.dart` - Web-specific implementation
- `lib/utils/url_utils_mobile.dart` - Mobile-specific implementation  
- `lib/utils/url_utils_stub.dart` - Fallback implementation

### 4. Integration in main.dart

The `_extractAndSaveBranchId()` function is called during app initialization:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... Hive initialization ...
  
  // Extract and save branch_id from URL
  await _extractAndSaveBranchId();
  
  // ... rest of initialization ...
}
```

## Usage

### Accessing Saved Branch ID
To retrieve the saved branch ID anywhere in your app:

```dart
import 'package:digital_menu_order/storage/local_storage.dart';

// Get the branch ID
final branchId = await LocalStorage.getBranchId();

if (branchId != null) {
  // Use the branch ID
  print('Current branch: $branchId');
}
```

### Clearing Branch ID
To clear the branch ID:

```dart
await LocalStorage.clearBranchId();
```

## Testing

### Web Testing
1. Run the app in web mode:
   ```bash
   flutter run -d chrome
   ```

2. Open the URL with a branch_id parameter:
   ```
   http://localhost:your_port/?branch_id=12345
   ```

3. Check the console logs - you should see:
   ```
   Branch ID found in URL: 12345
   Branch ID successfully saved to local storage
   ```

### Verifying Persistence
1. After loading with `?branch_id=12345`
2. Reload the page without the parameter
3. The app should print:
   ```
   No branch_id parameter found in URL
   Using previously saved branch ID: 12345
   ```

## QR Code URL Format

Generate QR codes with this format:
```
https://yourdomain.com/?branch_id=<BRANCH_ID>
```

Examples:
- Branch 101: `https://yourdomain.com/?branch_id=101`
- Branch ABC123: `https://yourdomain.com/?branch_id=ABC123`

## Additional Features

### Get All URL Parameters
You can also extract all URL parameters:

```dart
import 'package:digital_menu_order/utils/url_utils.dart';

final params = UrlUtils.getAllQueryParameters();
print(params); // {branch_id: 12345, other_param: value}
```

### Get Specific Parameter
```dart
final branchId = UrlUtils.getQueryParameter('branch_id');
final tableId = UrlUtils.getQueryParameter('table_id');
```

## Error Handling

The implementation includes comprehensive error handling:

- If URL parsing fails, it logs the error and continues
- If saving to SharedPreferences fails, it logs the error
- Missing parameters are handled gracefully
- Platform detection ensures web-only execution

## Integration with Existing Features

The branch ID is now automatically captured from the URL and saved. You can use it in:

- `BranchProvider` for fetching branch-specific data
- API calls that require branch ID
- Order creation that needs branch context
- Table selection based on branch

## Notes

- The branch ID persists across app sessions
- If a new branch_id is provided in the URL, it overwrites the old one
- On mobile platforms, the URL extraction returns null (no effect)
- The feature is automatically enabled for web/PWA builds

