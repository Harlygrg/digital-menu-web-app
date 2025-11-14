import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../services/api/api_service.dart';
import '../storage/local_storage.dart';

/// Provider for managing table screen state
class TableProvider extends ChangeNotifier {
  // API service
  final ApiService _apiService = ApiService();

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Data
  List<FloorModel> _floors = [];
  Set<int> _selectedTableIds = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<FloorModel> get floors => _floors;
  Set<int> get selectedTableIds => _selectedTableIds;
  List<TableModel> get selectedTables {
    final selectedTables = <TableModel>[];
    for (final floor in _floors) {
      for (final table in floor.tables) {
        if (_selectedTableIds.contains(table.tableId)) {
          selectedTables.add(table);
        }
      }
    }
    return selectedTables;
  }
  bool get hasSelectedTables => _selectedTableIds.isNotEmpty;
  int get selectedTableCount => _selectedTableIds.length;

  /// Fetch table list from API
  Future<void> fetchTableList() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check if we have a valid access token before making the request
      final accessToken = await LocalStorage.getAccessToken();
       String ? branchId = await LocalStorage.getBranchId() ;
      if (accessToken == null) {
        throw Exception('No access token available. Please register as a guest user first.');
      }
      if(branchId == null){
        _errorMessage = 'Error loading table list: No branch id available. Please select branch first.';
        throw Exception('No  branch id available. Please select branch first.');
      }

      final response = await _apiService.getTableList(branchId:branchId  );
      
      if (response.success) {
        _floors = response.floors;
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = response.message.isNotEmpty 
            ? response.message 
            : 'Failed to load table list from server';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('Error in fetchTableList: $e');
      _errorMessage = 'Error loading table list: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle table selection (single selection only)
  void toggleTableSelection(int tableId) {
    if (_selectedTableIds.contains(tableId)) {
      // If the same table is clicked again, deselect it
      _selectedTableIds.remove(tableId);
    } else {
      // Clear all previous selections and select the new table
      _selectedTableIds.clear();
      _selectedTableIds.add(tableId);
    }
    notifyListeners();
  }

  /// Select a table
  void selectTable(int tableId) {
    _selectedTableIds.add(tableId);
    notifyListeners();
  }

  /// Deselect a table
  void deselectTable(int tableId) {
    _selectedTableIds.remove(tableId);
    notifyListeners();
  }

  /// Check if a table is selected
  bool isTableSelected(int tableId) {
    return _selectedTableIds.contains(tableId);
  }

  /// Clear all table selections
  void clearAllSelections() {
    _selectedTableIds.clear();
    notifyListeners();
  }

  /// Select all tables from a specific floor
  void selectAllTablesFromFloor(int floorId) {
    final floor = _floors.firstWhere(
      (floor) => floor.floorId == floorId,
      orElse: () => throw Exception('Floor not found'),
    );
    
    for (final table in floor.tables) {
      _selectedTableIds.add(table.tableId);
    }
    notifyListeners();
  }

  /// Deselect all tables from a specific floor
  void deselectAllTablesFromFloor(int floorId) {
    final floor = _floors.firstWhere(
      (floor) => floor.floorId == floorId,
      orElse: () => throw Exception('Floor not found'),
    );
    
    for (final table in floor.tables) {
      _selectedTableIds.remove(table.tableId);
    }
    notifyListeners();
  }

  /// Get selected tables count for a specific floor
  int getSelectedTablesCountForFloor(int floorId) {
    final floor = _floors.firstWhere(
      (floor) => floor.floorId == floorId,
      orElse: () => throw Exception('Floor not found'),
    );
    
    int count = 0;
    for (final table in floor.tables) {
      if (_selectedTableIds.contains(table.tableId)) {
        count++;
      }
    }
    return count;
  }

  /// Check if all tables from a floor are selected
  bool areAllTablesFromFloorSelected(int floorId) {
    final floor = _floors.firstWhere(
      (floor) => floor.floorId == floorId,
      orElse: () => throw Exception('Floor not found'),
    );
    
    if (floor.tables.isEmpty) return false;
    
    for (final table in floor.tables) {
      if (!_selectedTableIds.contains(table.tableId)) {
        return false;
      }
    }
    return true;
  }

  /// Get table by ID
  TableModel? getTableById(int tableId) {
    for (final floor in _floors) {
      for (final table in floor.tables) {
        if (table.tableId == tableId) {
          return table;
        }
      }
    }
    return null;
  }

  /// Get floor by ID
  FloorModel? getFloorById(int floorId) {
    try {
      return _floors.firstWhere((floor) => floor.floorId == floorId);
    } catch (e) {
      return null;
    }
  }

  /// Get selected tables for a specific floor
  List<TableModel> getSelectedTablesForFloor(int floorId) {
    final floor = _floors.firstWhere(
      (floor) => floor.floorId == floorId,
      orElse: () => throw Exception('Floor not found'),
    );
    
    return floor.tables
        .where((table) => _selectedTableIds.contains(table.tableId))
        .toList();
  }

  /// Reset provider state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _floors.clear();
    _selectedTableIds.clear();
    notifyListeners();
  }

  /// Force re-authentication by clearing tokens and re-registering
  Future<void> forceReAuthentication() async {
    try {
      await LocalStorage.clearAuthData();
      _errorMessage = 'Authentication expired. Please restart the app to re-authenticate.';
      notifyListeners();
    } catch (e) {
      print('Error during force re-authentication: $e');
    }
  }

  /// Check authentication status
  Future<bool> isAuthenticated() async {
    final accessToken = await LocalStorage.getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}
