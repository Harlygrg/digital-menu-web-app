import 'package:digital_menu_order/utils/qr_init_context.dart';
import 'package:flutter/material.dart';
import '../models/branch_model.dart';
import '../services/api/api_service.dart';
import '../storage/local_storage.dart';
import 'package:digital_menu_order/utils/app_debug_log.dart';

/// Provider for managing branch selection state
class BranchProvider extends ChangeNotifier {
  // State
  bool _isLoading = false;
  String? _errorMessage;
  List<BranchModel> _branches = [];
  BranchModel? _selectedBranch;
  String? _savedBranchId; // Cache the saved branch ID for quick access
  bool _isInitialized = false; // Track if initial load is complete

  // Constructor - Initialize by loading saved branch ID
  BranchProvider() {
    _loadSavedBranchId();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BranchModel> get branches => _branches;
  BranchModel? get selectedBranch => _selectedBranch;
  String? get selectedBranchId => _selectedBranch?.id.toString();
  bool get isInitialized => _isInitialized;

  /// Load saved branch ID from local storage on initialization
  Future<void> _loadSavedBranchId() async {
    try {
      _savedBranchId = await LocalStorage.getBranchId();
      if (_savedBranchId != null) {
        appDebugLog('✅ Saved branch ID loaded in provider: $_savedBranchId');
      } else {
        appDebugLog('ℹ️ No saved branch ID found in provider initialization');
      }
    } catch (e) {
      appDebugLog('❌ Error loading saved branch ID: $e');
    }
  }

  // setBranchLoading(bool isLoading){
  //   _isLoading = isLoading;
  //   notifyListeners();
  // }

  /// Fetch branch list from API
  ///
  /// [silentRefresh] - If true, skips loading state updates to prevent UI stuttering during pull-to-refresh
  Future<void> fetchBranchList({bool silentRefresh = false}) async {
    try {
      // Only show loading state if not a silent refresh
      if (!silentRefresh) {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();
      } else {
        // For silent refresh, just clear error message without triggering rebuild
        _errorMessage = null;
      }

      final apiService = ApiService();
      final response = await apiService.getBranchList();

      if (response.success) {
        // Yield to frame scheduler for smoother refresh animation
        await Future.delayed(Duration.zero);

        _branches = response.branches
            .where((branch) => branch.isActive)
            .toList();
        appDebugLog('✅ Fetched ${_branches.length} active branches');

        // Reload saved branch ID to ensure we have the latest
        _savedBranchId = QrInitContext.branchId?.toString()
            ?? await LocalStorage.getBranchId();

        // If there's a saved branch ID, try to match it with fetched branches
        if (_savedBranchId != null && _savedBranchId!.isNotEmpty) {
          appDebugLog('🔍 Looking for saved branch ID: $_savedBranchId');

          try {
            _selectedBranch = _branches.firstWhere(
              (branch) => branch.id.toString() == _savedBranchId,
            );
            appDebugLog(
              '✅ Matched saved branch: ${_selectedBranch?.cname} (ID: $_savedBranchId)',
            );
          } catch (e) {
            // Branch not found in the list
            appDebugLog(
              '⚠️ Saved branch ID $_savedBranchId not found in active branches',
            );
            appDebugLog(
              '   Available branch IDs: ${_branches.map((b) => b.id).join(", ")}',
            );

            // Clear the invalid saved ID
            await LocalStorage.clearBranchId();
            _savedBranchId = null;
            _selectedBranch = null;
          }
        } else {
          appDebugLog('ℹ️ No saved branch ID to match');
          _selectedBranch = null;
        }

        _isInitialized = true;
        _isLoading = false;

        // Only notify once at the end to batch all updates into a single rebuild
        notifyListeners();

        appDebugLog(
          '📊 Branch Provider State: hasBranchSelected = $hasBranchSelected, selectedBranch = ${_selectedBranch?.cname}',
        );
      } else {
        _errorMessage = 'Failed to load branch list';
        _isLoading = false;
        _isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      appDebugLog('❌ Error fetching branch list: $e');
      _errorMessage = 'Error loading branches: ${e.toString()}';
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Select a branch
  ///
  /// [branch] - The branch to select
  /// [clearCart] - Callback function to clear cart when branch changes
  Future<void> selectBranch(
    BranchModel branch, {
    required Function() clearCart,
  }) async {
    try {
      // Check if switching from an existing branch
      final previousBranchId =
          _savedBranchId ?? await LocalStorage.getBranchId();

      if (previousBranchId != null &&
          previousBranchId != branch.id.toString()) {
        // Branch is changing - clear cart
        clearCart();
        appDebugLog('🛒 Cart cleared due to branch change');
      }

      // Update selected branch
      _selectedBranch = branch;
      _savedBranchId = branch.id.toString();

      // Save to SharedPreferences
      await LocalStorage.saveBranchId(branch.id.toString());
      appDebugLog(
        '✅ Branch selected and saved: ${branch.cname} (ID: ${branch.id})',
      );

      notifyListeners();
    } catch (e) {
      appDebugLog('❌ Error selecting branch: $e');
      _errorMessage = 'Error selecting branch: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Clear branch selection
  Future<void> clearBranchSelection() async {
    try {
      _selectedBranch = null;
      _savedBranchId = null;
      await LocalStorage.clearBranchId();
      appDebugLog('🗑️ Branch selection cleared');
      notifyListeners();
    } catch (e) {
      appDebugLog('❌ Error clearing branch selection: $e');
    }
  }

  /// Check if a branch is selected
  bool get hasBranchSelected => _selectedBranch != null;

  /// Get branch by ID (using cached saved branch ID if available)
  Future<BranchModel?> getBranchById() async {
    try {
      // Use cached saved branch ID if available, otherwise fetch from storage
      final savedBranchId = _savedBranchId ?? await LocalStorage.getBranchId();

      if (savedBranchId != null && savedBranchId.isNotEmpty) {
        appDebugLog('🔍 Getting branch by ID: $savedBranchId');
        return _branches.firstWhere(
          (branch) => branch.id.toString() == savedBranchId,
        );
      }
      return null;
    } catch (e) {
      appDebugLog('⚠️ Branch with saved ID not found: $e');
      return null;
    }
  }
}
