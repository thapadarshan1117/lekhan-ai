import 'package:permission_handler/permission_handler.dart';

/// Runtime permissions the offline features need.
enum AppPermission {
  /// Voice recording.
  microphone,

  /// Capturing scans / photos as source material.
  camera,

  /// Picking existing images from the gallery (Android 13+/iOS 14+).
  photos,

  /// Reminder / sync notifications.
  notifications,
}

/// Result of a permission request, kept small on purpose so the UI can decide
/// between "ask again" and "send the user to settings".
class PermissionOutcome {
  const PermissionOutcome({
    required this.granted,
    required this.permanentlyDenied,
  });

  final bool granted;
  final bool permanentlyDenied;

  static const PermissionOutcome grantedOutcome =
      PermissionOutcome(granted: true, permanentlyDenied: false);
}

/// Wraps `permission_handler` so features never import it directly.
class PermissionService {
  const PermissionService();

  Future<bool> isGranted(AppPermission permission) async {
    try {
      final PermissionStatus status = await _resolve(permission).status;
      return status.isGranted || status.isLimited;
    } catch (_) {
      return false;
    }
  }

  /// Asks for the permission if it has not been decided yet.
  ///
  /// [acceptPartial] is used for media access, where the OS may hand back
  /// "limited" instead of a full grant.
  Future<PermissionOutcome> ensure(
    AppPermission permission, {
    bool acceptPartial = true,
  }) async {
    try {
      final Permission target = _resolve(permission);
      PermissionStatus status = await target.status;

      if (status.isGranted || (acceptPartial && status.isLimited)) {
        return PermissionOutcome.grantedOutcome;
      }

      if (status.isPermanentlyDenied || status.isRestricted) {
        return const PermissionOutcome(
          granted: false,
          permanentlyDenied: true,
        );
      }

      status = await target.request();

      final bool granted = status.isGranted || (acceptPartial && status.isLimited);
      return PermissionOutcome(
        granted: granted,
        permanentlyDenied: status.isPermanentlyDenied || status.isRestricted,
      );
    } catch (_) {
      return const PermissionOutcome(granted: false, permanentlyDenied: false);
    }
  }

  /// Convenience for the recording flow: true when we may open the mic.
  Future<bool> ensureMicrophone() async {
    final PermissionOutcome outcome = await ensure(AppPermission.microphone);
    return outcome.granted;
  }

  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }

  Permission _resolve(AppPermission permission) {
    switch (permission) {
      case AppPermission.microphone:
        return Permission.microphone;
      case AppPermission.camera:
        return Permission.camera;
      case AppPermission.photos:
        return Permission.photos;
      case AppPermission.notifications:
        return Permission.notification;
    }
  }
}
