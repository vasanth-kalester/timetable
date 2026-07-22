import '../models/admin_models.dart';

class ConfigurationService {
  SystemConfig _currentConfig;

  ConfigurationService(this._currentConfig);

  /// Get the active system configuration.
  SystemConfig get config => _currentConfig;

  /// Update the system configuration after validating it.
  void updateConfig(SystemConfig newConfig) {
    // Validation 1: Must have at least 1 working day
    if (newConfig.workingDays.isEmpty) {
      throw Exception('System must have at least one working day.');
    }

    // Validation 2: Time slots must be > 0
    if (newConfig.defaultTimeSlotsPerDay <= 0) {
      throw Exception('Default time slots per day must be greater than zero.');
    }

    // Apply
    _currentConfig = newConfig;
  }

  /// Helper to check permissions dynamically
  bool hasPermission(String role, String action) {
    final permissions = _currentConfig.rolePermissions[role];
    if (permissions == null) return false;
    
    // Wildcard support for admins
    if (permissions.contains('*')) return true;
    
    return permissions.contains(action);
  }
}
