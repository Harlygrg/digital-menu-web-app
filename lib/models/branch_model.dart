/// Branch models for API response parsing
/// 
/// This file contains models for handling branch list API responses.

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

/// Model representing a single branch
class BranchModel {
  final int id;
  final String cname;
  final int active;

  const BranchModel({
    required this.id,
    required this.cname,
    required this.active,
  });

  /// Create from JSON
  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: _safeToInt(json['ID']),
      cname: json['Cname'] ?? '',
      active: _safeToInt(json['Active']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Cname': cname,
      'Active': active,
    };
  }

  /// Check if branch is active
  bool get isActive => active == 1;

  /// Create a copy with updated properties
  BranchModel copyWith({
    int? id,
    String? cname,
    int? active,
  }) {
    return BranchModel(
      id: id ?? this.id,
      cname: cname ?? this.cname,
      active: active ?? this.active,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BranchModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BranchModel(id: $id, cname: $cname, active: $active)';
  }
}

/// Model representing the complete branch list API response
class BranchListResponse {
  final bool success;
  final String message;
  final List<BranchModel> branches;

  const BranchListResponse({
    required this.success,
    required this.message,
    required this.branches,
  });

  /// Create from JSON
  factory BranchListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    return BranchListResponse(
      success: json['success'] ?? false,
      message: data['message'] ?? '',
      branches: (data['branches'] as List<dynamic>?)
          ?.map((item) => BranchModel.fromJson(item))
          .toList() ?? [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': {
        'message': message,
        'branches': branches.map((branch) => branch.toJson()).toList(),
      },
    };
  }

  @override
  String toString() {
    return 'BranchListResponse(success: $success, branches: ${branches.length})';
  }
}

