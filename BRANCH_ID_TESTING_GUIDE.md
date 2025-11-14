# Branch ID Fix - Quick Testing Guide

## 🚀 Quick Start

### Prerequisites
- Flutter development environment set up
- App connected to test device/emulator
- Access to app logs/console

## 📝 Test Scenarios

### Scenario 1: First Time User (No Branch ID)
**Steps:**
1. Clear app data completely
2. Launch app without URL parameters
3. Observe the branch dropdown widget

**Expected Behavior:**
- Brief shimmer loading
- Branch dropdown appears with "Select Branch" text
- User can tap and select a branch
- After selection, branch name replaces dropdown

**Console Logs to Verify:**
```
ℹ️ No branch_id parameter found in URL
ℹ️ No previously saved branch ID found
ℹ️ No saved branch ID found in provider initialization
📋 Showing branch dropdown (no branch selected)
```

---

### Scenario 2: Returning User (Has Saved Branch)
**Steps:**
1. User has previously selected a branch
2. Close and reopen app
3. Observe the branch display

**Expected Behavior:**
- Brief shimmer loading
- Branch **name** appears directly (no dropdown)
- Menu items load for that branch
- No need to select branch again

**Console Logs to Verify:**
```
✅ Using previously saved branch ID: 5
✅ Saved branch ID loaded in provider: 5
✅ Matched saved branch: Main Branch (ID: 5)
🏪 Showing branch name: Main Branch
```

---

### Scenario 3: URL with Branch ID Parameter
**Steps:**
1. Clear app data
2. Open app with URL: `https://yourapp.com/?branch_id=3`
3. Wait for initialization

**Expected Behavior:**
- Branch ID "3" is extracted and saved
- After branch list loads, branch name for ID 3 appears
- No dropdown shown
- Products for branch 3 are loaded

**Console Logs to Verify:**
```
✅ Branch ID found in URL: 3
✅ Branch ID successfully saved to local storage: 3
✅ Matched saved branch: Downtown Branch (ID: 3)
🏪 Showing branch name: Downtown Branch
📦 Fetching product data for branch: 3
```

---

### Scenario 4: Changing Branches (With Cart Items)
**Steps:**
1. Have a branch selected
2. Add items to cart
3. Tap the branch name to open selection dialog
4. Select a different branch

**Expected Behavior:**
- Warning dialog appears about cart clearing
- After confirmation, cart is emptied
- New branch name appears
- Products for new branch load
- Success snackbar shows

**Console Logs to Verify:**
```
✅ Branch selected and saved: New Branch (ID: 7)
🛒 Cart cleared due to branch change
📦 Fetching product data for branch: 7
```

---

### Scenario 5: Invalid Branch ID Handling
**Steps:**
1. Manually edit local storage to have branch ID "999"
2. Restart app
3. Observe behavior

**Expected Behavior:**
- App detects invalid branch ID
- Invalid ID is cleared
- Dropdown appears for branch selection
- No crash or error shown to user

**Console Logs to Verify:**
```
⚠️ Saved branch ID 999 not found in active branches
   Available branch IDs: 1, 2, 3, 5, 7
📋 Showing branch dropdown (no branch selected)
```

---

## 🔧 Manual Testing Checklist

- [ ] **Branch dropdown shows** when no branch is saved
- [ ] **Branch name shows** when a branch is saved
- [ ] **URL parameter works** - branch ID from URL is saved
- [ ] **Branch persistence works** - selected branch remains after app restart
- [ ] **Branch switching works** - can change branches via dialog
- [ ] **Cart clearing works** - cart clears when changing branches
- [ ] **Invalid ID handling** - gracefully handles invalid branch IDs
- [ ] **Shimmer loading** - shows loading state during initialization
- [ ] **Success snackbar** - shows confirmation after branch selection
- [ ] **Warning dialog** - shows when switching branches with items in cart

---

## 🐛 Troubleshooting

### Issue: Dropdown always shows (never shows branch name)

**Check:**
1. Look for logs: `⚠️ Saved branch ID X not found in active branches`
2. Verify saved branch ID matches an active branch
3. Check if API is returning branches

**Fix:** Clear app data and select a valid branch

---

### Issue: Branch name shows but wrong branch

**Check:**
1. Verify what branch ID is saved in local storage
2. Check logs for: `✅ Matched saved branch: [Name] (ID: X)`
3. Confirm API returns correct branch data

**Fix:** Clear saved branch ID and reselect

---

### Issue: Shimmer never ends

**Check:**
1. Check if `fetchBranchList()` completes
2. Look for API errors in logs
3. Verify network connectivity

**Fix:** Check API endpoint and authentication

---

## 📊 Expected Debug Logs Flow

### Complete Successful Flow:
```
🔍 _extractAndSaveBranchId: Starting extraction...
✅ Branch ID found in URL: 5
✅ Branch ID successfully saved to local storage: 5
✅ Saved branch ID loaded in provider: 5
🚀 HomeController: initialize started
👤 Guest user not registered or no access token. Registering...
✅ Guest user registered successfully
🏪 Fetching branch list...
✅ Fetched 10 active branches
🔍 Looking for saved branch ID: 5
✅ Matched saved branch: Main Branch (ID: 5)
📊 Branch Provider State: hasBranchSelected = true, selectedBranch = Main Branch
✅ Branch list fetched successfully
📦 Fetching product data for branch: 5
📦 HomeProvider: fetchProductRelatedData for branch 5
✅ Loaded 15 categories, 120 items, 45 modifiers
✅ Initialization complete
🏪 Showing branch name: Main Branch
```

---

## ✅ Success Criteria

The fix is working correctly if:

1. **With saved branch ID**: App shows branch name immediately after initialization
2. **Without saved branch ID**: App shows dropdown for selection
3. **URL parameter**: Branch ID from URL is used and persisted
4. **State persistence**: Branch selection survives app restart
5. **Cart clearing**: Cart empties when switching branches
6. **Error handling**: Invalid branch IDs are handled gracefully
7. **UI updates**: UI updates reactively to branch state changes
8. **Logging**: All debug logs appear correctly showing the flow

---

## 📱 Device Testing

Test on:
- [ ] Android device
- [ ] iOS device  
- [ ] Web browser
- [ ] Different screen sizes (phone/tablet)
- [ ] Both portrait and landscape orientations

---

## 🎯 Key Things to Verify

1. **No dropdown appears** when there's a valid saved branch ID
2. **Branch name is displayed** correctly when branch is selected
3. **Dropdown only appears** when no branch is selected
4. **All state changes trigger UI updates** properly
5. **Console logs are helpful** for debugging

---

**Testing Date**: _____________  
**Tested By**: _____________  
**Platform**: _____________  
**Result**: ☐ Pass ☐ Fail  
**Notes**: _____________________________________________

