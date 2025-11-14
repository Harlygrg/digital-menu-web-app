import 'package:flutter/material.dart';

/// Table and Floor models for API response parsing
/// 
/// This file contains models for handling table list API responses,
/// including floor and table data structures.

/// Helper function to safely convert dynamic values to int
int _safeToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

/// Model representing a single table
class TableModel {
  final int tableId;
  final String tableName;
  final int tableOrder;
  final String tableColour;
  final String tableFont;
  final String fontColour;

  const TableModel({
    required this.tableId,
    required this.tableName,
    required this.tableOrder,
    required this.tableColour,
    required this.tableFont,
    required this.fontColour,
  });

  /// Create from JSON
  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      tableId: _safeToInt(json['table_id']),
      tableName: json['table_name'] ?? '',
      tableOrder: _safeToInt(json['table_order']),
      tableColour: json['table_colour'] ?? '-1',
      tableFont: json['table_font'] ?? 'Arial',
      fontColour: json['font_colour'] ?? '0',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'table_id': tableId,
      'table_name': tableName,
      'table_order': tableOrder,
      'table_colour': tableColour,
      'table_font': tableFont,
      'font_colour': fontColour,
    };
  }

  /// Get table color as Color object
  /// Returns a default color if tableColour is invalid
  Color get tableColor {
    try {
      // Handle special cases
      if (tableColour == '-1') {
        return const Color(0xFFE0E0E0); // Default light gray
      }
      
      // Try to parse as hex color
      if (tableColour.startsWith('#')) {
        return Color(int.parse(tableColour.substring(1), radix: 16) + 0xFF000000);
      }
      
      // Try to parse as integer
      final colorValue = int.tryParse(tableColour);
      if (colorValue != null) {
        return Color(colorValue + 0xFF000000);
      }
      
      return const Color(0xFFE0E0E0); // Default fallback
    } catch (e) {
      return const Color(0xFFE0E0E0); // Default fallback
    }
  }

  /// Get font color as Color object
  Color get fontColor {
    try {
      if (fontColour == '0') {
        return const Color(0xFF000000); // Black
      }
      
      // Try to parse as hex color
      if (fontColour.startsWith('#')) {
        return Color(int.parse(fontColour.substring(1), radix: 16) + 0xFF000000);
      }
      
      // Try to parse as integer
      final colorValue = int.tryParse(fontColour);
      if (colorValue != null) {
        return Color(colorValue + 0xFF000000);
      }
      
      return const Color(0xFF000000); // Default black
    } catch (e) {
      return const Color(0xFF000000); // Default black
    }
  }

  /// Create a copy with updated properties
  TableModel copyWith({
    int? tableId,
    String? tableName,
    int? tableOrder,
    String? tableColour,
    String? tableFont,
    String? fontColour,
  }) {
    return TableModel(
      tableId: tableId ?? this.tableId,
      tableName: tableName ?? this.tableName,
      tableOrder: tableOrder ?? this.tableOrder,
      tableColour: tableColour ?? this.tableColour,
      tableFont: tableFont ?? this.tableFont,
      fontColour: fontColour ?? this.fontColour,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TableModel && other.tableId == tableId;
  }

  @override
  int get hashCode => tableId.hashCode;

  @override
  String toString() {
    return 'TableModel(tableId: $tableId, tableName: $tableName)';
  }
}

/// Model representing a floor with its tables
class FloorModel {
  final int floorId;
  final String floorName;
  final int tableCount;
  final String tablePrefix;
  final int dineinOrder;
  final List<TableModel> tables;

  const FloorModel({
    required this.floorId,
    required this.floorName,
    required this.tableCount,
    required this.tablePrefix,
    required this.dineinOrder,
    required this.tables,
  });

  /// Create from JSON
  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      floorId: _safeToInt(json['floor_id']),
      floorName: json['floor_name'] ?? '',
      tableCount: _safeToInt(json['table_count']),
      tablePrefix: json['table_prefix'] ?? '',
      dineinOrder: _safeToInt(json['dinein_order']),
      tables: (json['tables'] as List<dynamic>?)
          ?.map((item) => TableModel.fromJson(item))
          .toList() ?? [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'floor_id': floorId,
      'floor_name': floorName,
      'table_count': tableCount,
      'table_prefix': tablePrefix,
      'dinein_order': dineinOrder,
      'tables': tables.map((table) => table.toJson()).toList(),
    };
  }

  /// Create a copy with updated properties
  FloorModel copyWith({
    int? floorId,
    String? floorName,
    int? tableCount,
    String? tablePrefix,
    int? dineinOrder,
    List<TableModel>? tables,
  }) {
    return FloorModel(
      floorId: floorId ?? this.floorId,
      floorName: floorName ?? this.floorName,
      tableCount: tableCount ?? this.tableCount,
      tablePrefix: tablePrefix ?? this.tablePrefix,
      dineinOrder: dineinOrder ?? this.dineinOrder,
      tables: tables ?? this.tables,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FloorModel && other.floorId == floorId;
  }

  @override
  int get hashCode => floorId.hashCode;

  @override
  String toString() {
    return 'FloorModel(floorId: $floorId, floorName: $floorName, tableCount: $tableCount)';
  }
}

/// Model representing the complete table list API response
class TableListResponse {
  final bool success;
  final String message;
  final int branchId;
  final List<FloorModel> floors;

  const TableListResponse({
    required this.success,
    required this.message,
    required this.branchId,
    required this.floors,
  });

  /// Create from JSON
  factory TableListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    return TableListResponse(
      success: json['success'] ?? false,
      message: data['message'] ?? '',
      branchId: _safeToInt(data['branch_id']),
      floors: (data['floors'] as List<dynamic>?)
          ?.map((item) => FloorModel.fromJson(item))
          .toList() ?? [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': {
        'message': message,
        'branch_id': branchId,
        'floors': floors.map((floor) => floor.toJson()).toList(),
      },
    };
  }

  @override
  String toString() {
    return 'TableListResponse(success: $success, branchId: $branchId, floors: ${floors.length})';
  }
}
