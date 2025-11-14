# Image URL Feature - Quick Testing Guide

## Overview
This guide helps you quickly test the new `image_url` field functionality in the Digital Menu app.

---

## Prerequisites
- Digital Menu app running on emulator/device
- Access to backend API or ability to mock API responses
- Test images available (both base64 and URLs)

---

## Test Scenarios

### 🧪 Scenario 1: Product with Base64 Image Only (Existing Behavior)

**API Response Mock**:
```json
{
  "Id": 1,
  "Iname": "Classic Burger",
  "image": "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
  "image_url": null,
  "Price": "25.00"
}
```

**Expected Result**:
- ✅ Image loads from base64 string
- ✅ Uses `Image.memory` widget
- ✅ No network request made
- ✅ Same behavior as before the update

**Where to Check**:
- Home screen (grid view)
- Home screen (list view)
- Product description popup
- Cart screen

---

### 🧪 Scenario 2: Product with Image URL Only (New Feature)

**API Response Mock**:
```json
{
  "Id": 2,
  "Iname": "Veggie Pizza",
  "image": "",
  "image_url": "https://images.unsplash.com/photo-1513104890138-7c749659a591",
  "Price": "35.00"
}
```

**Expected Result**:
- ✅ Image loads from network URL
- ✅ Uses `CachedNetworkImage` widget
- ✅ Shows loading indicator while fetching
- ✅ Image is cached for subsequent loads

**How to Verify Caching**:
1. Load product first time (watch network indicator)
2. Scroll away and back (should load instantly from cache)
3. Restart app and view again (should still be cached)

**Where to Check**:
- Home screen (grid view) - Line 125-127
- Home screen (list view) - Line 120-122
- Product description popup - Line 65-67
- Cart screen - Line 305-307

---

### 🧪 Scenario 3: Product with Both Base64 and URL (Priority Test)

**API Response Mock**:
```json
{
  "Id": 3,
  "Iname": "Chicken Pasta",
  "image": "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
  "image_url": "https://example.com/different-image.jpg",
  "Price": "30.00"
}
```

**Expected Result**:
- ✅ **Base64 image loads** (not the URL image)
- ✅ Uses `Image.memory` widget
- ✅ Network image URL is ignored
- ✅ Verifies priority: Base64 > URL > Error

**How to Verify**:
- Ensure the loaded image matches the base64 data
- Check network tab - should see no request to the URL
- Base64 should "win" in all cases

---

### 🧪 Scenario 4: Product with No Images (Fallback Test)

**API Response Mock**:
```json
{
  "Id": 4,
  "Iname": "Special Dish",
  "image": "",
  "image_url": null,
  "Price": "40.00"
}
```

**Expected Result**:
- ✅ Shows placeholder icon (fastfood icon)
- ✅ Container has light background color
- ✅ No error in console
- ✅ App remains stable

**Visual Check**:
- Icon should be `Icons.fastfood`
- Background should be primary color with low opacity
- Layout should not break

---

### 🧪 Scenario 5: Invalid Network URL (Error Handling Test)

**API Response Mock**:
```json
{
  "Id": 5,
  "Iname": "Mystery Meal",
  "image": "",
  "image_url": "https://invalid-domain-that-does-not-exist.com/image.jpg",
  "Price": "20.00"
}
```

**Expected Result**:
- ✅ Attempts to load from URL
- ✅ Fails gracefully
- ✅ Shows placeholder icon
- ✅ No app crash
- ✅ Error handled silently

**Console Check**:
- May see network error (expected)
- Should not see any Flutter errors
- Should not impact other products

---

### 🧪 Scenario 6: Slow Network (Loading State Test)

**Setup**:
1. Enable network throttling (slow 3G)
2. Use product with `image_url`
3. Scroll to new products

**Expected Result**:
- ✅ Shows loading placeholder (if provided)
- ✅ Eventually loads image
- ✅ No UI freeze or blocking
- ✅ Other products load independently

**Performance Check**:
- App remains responsive during image load
- Scrolling is smooth
- Multiple images can load in parallel

---

## Testing Checklist

### Visual Testing
- [ ] Grid view shows images correctly
- [ ] List view shows images correctly  
- [ ] Product popup shows images correctly
- [ ] Cart screen shows images correctly
- [ ] Images maintain aspect ratio
- [ ] No image flickering or jumping
- [ ] Rounded corners are preserved
- [ ] Error icons are centered

### Functional Testing
- [ ] Base64 images load (existing feature works)
- [ ] Network images load (new feature works)
- [ ] Base64 has priority over URL
- [ ] Placeholder shows when no image
- [ ] Invalid URLs fail gracefully
- [ ] Images are cached properly
- [ ] Memory usage is reasonable

### Performance Testing
- [ ] No stuttering when scrolling
- [ ] Fast image loading on good network
- [ ] Acceptable loading on slow network
- [ ] Cached images load instantly
- [ ] Multiple images load in parallel
- [ ] App doesn't hang on image load

### Edge Cases
- [ ] Empty string vs null handling
- [ ] Very large images (>5MB)
- [ ] Very small images (<1KB)
- [ ] Different image formats (jpg, png, webp)
- [ ] Portrait vs landscape images
- [ ] Corrupted base64 data
- [ ] Redirect URLs (301/302)

---

## Test Data Samples

### Valid Test URLs
```
https://images.unsplash.com/photo-1546069901-ba9599a7e63c (burger)
https://images.unsplash.com/photo-1513104890138-7c749659a591 (pizza)
https://images.unsplash.com/photo-1555939594-58d7cb561ad1 (pasta)
```

### Base64 Sample (1x1 red pixel)
```
data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==
```

---

## Debugging Tips

### Check Image Source
Add temporary logging in `image_utils.dart`:
```dart
if (base64String.isNotEmpty) {
  print('🖼️ Loading from base64');
} else if (imageUrl != null && imageUrl.isNotEmpty) {
  print('🌐 Loading from URL: $imageUrl');
} else {
  print('⚠️ No image available, showing placeholder');
}
```

### Monitor Network Requests
- Open DevTools Network tab
- Filter by image requests
- Verify `CachedNetworkImage` requests appear
- Check for 200 responses

### Check Cache
```dart
// In a temporary test method
import 'package:cached_network_image/cached_network_image.dart';

await DefaultCacheManager().emptyCache();
print('Cache cleared');
```

### Verify Model Parsing
```dart
// Add in API service or provider
print('Item ${item.id}: image length=${item.image.length}, imageUrl=${item.imageUrl}');
```

---

## Common Issues & Solutions

### Issue: Network images not loading
**Solution**: 
- Check internet permissions in `AndroidManifest.xml` and `Info.plist`
- Verify URL is accessible (try in browser)
- Check for CORS issues (web platform)

### Issue: Images flicker when scrolling
**Solution**:
- Already handled by `gaplessPlayback: true`
- Ensure cache is working properly
- Check if images are too large (optimize on backend)

### Issue: Memory usage high
**Solution**:
- Use `cacheWidth` and `cacheHeight` parameters
- Backend should optimize image sizes
- Consider image compression

### Issue: Placeholder not showing
**Solution**:
- Verify both `image` and `imageUrl` are actually empty
- Check error widget is properly defined
- Ensure default error widget displays

---

## Success Criteria

The implementation is successful if:

✅ All existing base64 images continue to work  
✅ New URL-based images load correctly  
✅ Priority logic works (base64 > URL > placeholder)  
✅ No performance degradation  
✅ No visual glitches or flicker  
✅ Proper error handling for all scenarios  
✅ Caching works as expected  
✅ Memory usage is acceptable  

---

## Automated Testing (Optional)

### Widget Test Example
```dart
testWidgets('ImageUtils loads from URL when base64 is empty', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ImageUtils.buildImageFromBase64(
          '',
          imageUrl: 'https://example.com/test.jpg',
        ),
      ),
    ),
  );
  
  await tester.pump();
  
  expect(find.byType(CachedNetworkImage), findsOneWidget);
});
```

### Integration Test Example
```dart
testWidgets('Product with imageUrl displays correctly', (tester) async {
  // Mock API response with image_url
  // Navigate to home screen
  // Verify image loads
  // Verify no errors
});
```

---

## Reporting Issues

When reporting issues, include:
1. **Scenario**: Which test case (1-6)
2. **Device**: iOS/Android/Web, version
3. **Network**: WiFi/Mobile/Offline
4. **Expected**: What should happen
5. **Actual**: What actually happened
6. **Screenshots**: Visual proof
7. **Logs**: Console output/errors

---

## Sign-off

After completing all tests:

- [ ] All test scenarios pass
- [ ] No regressions found
- [ ] Performance is acceptable
- [ ] Documentation is clear
- [ ] Ready for production

**Tested by**: _____________  
**Date**: _____________  
**Approved**: _____________  

---

## Quick Command Reference

```bash
# Clear Flutter cache
flutter clean

# Rebuild app
flutter run

# Check for issues
flutter analyze

# Run tests
flutter test

# Build release
flutter build apk # Android
flutter build ios # iOS
flutter build web # Web
```

---

**Happy Testing! 🚀**

