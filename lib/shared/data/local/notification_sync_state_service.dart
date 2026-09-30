import 'package:hive_ce/hive.dart';

class NotificationSyncStateService {
  static const String _boxName = 'notification_state';

  Future<Box> _box() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<void> setSystemAuthorized(bool value) async {
    final box = await _box();
    await box.put('systemAuthorized', value);
  }

  Future<bool> getSystemAuthorized() async {
    final box = await _box();
    return (box.get('systemAuthorized') ?? false) as bool;
  }

  Future<void> setTokenSyncedToServer(bool value) async {
    final box = await _box();
    await box.put('tokenSyncedToServer', value);
  }

  Future<bool> getTokenSyncedToServer() async {
    final box = await _box();
    return (box.get('tokenSyncedToServer') ?? false) as bool;
  }

  Future<void> setLastToken(String? token) async {
    final box = await _box();
    if (token == null) {
      await box.delete('lastToken');
    } else {
      await box.put('lastToken', token);
    }
  }

  Future<String?> getLastToken() async {
    final box = await _box();
    return box.get('lastToken') as String?;
  }

  Future<void> setLastSyncAt(DateTime? time) async {
    final box = await _box();
    if (time == null) {
      await box.delete('lastSyncAt');
    } else {
      await box.put('lastSyncAt', time.millisecondsSinceEpoch);
    }
  }

  Future<DateTime?> getLastSyncAt() async {
    final box = await _box();
    final ms = box.get('lastSyncAt') as int?;
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }
}
