import '../models/user_model.dart';

class PermissionHelper {
  final UserRole? role;

  PermissionHelper(this.role);

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is worker
  bool get isWorker => role == UserRole.worker;

  /// Check if user is viewer
  bool get isViewer => role == UserRole.viewer;

  /// Can the user add/edit workers?
  bool get canManageWorkers => role?.canManageWorkers ?? false;

  /// Can the user create transactions (distribute/return/purchase)?
  bool get canCreateTransactions => role?.canCreateTransactions ?? false;

  /// Can the user delete workers?
  bool get canDeleteWorkers => role?.canDeleteWorkers ?? false;

  /// Can the user edit workers?
  bool get canEditWorkers => role?.canEditWorkers ?? false;

  /// Can the user view reports?
  bool get canViewReports => role?.canViewReports ?? false;

  /// Can the user export data?
  bool get canExportData => role?.canExportData ?? false;

  /// Can the user manage users?
  bool get canManageUsers => role?.canManageUsers ?? false;

  /// Can the user manage settings?
  bool get canManageSettings => role?.canManageSettings ?? false;

  /// Is the user in read-only mode?
  bool get isReadOnly => role == UserRole.viewer;

  /// Should show the add worker FAB?
  bool get showAddWorkerButton => canManageWorkers;

  /// Should show transaction buttons (distribute, return, purchase)?
  bool get showTransactionButtons => canCreateTransactions;

  /// Should show edit button on worker detail?
  bool get showEditButton => canEditWorkers;

  /// Should show delete button on worker detail?
  bool get showDeleteButton => canDeleteWorkers;

  /// Get role display name
  String get roleDisplayName => role?.displayName ?? 'Unknown';

  /// Get role description
  String get roleDescription => role?.description ?? '';
}
