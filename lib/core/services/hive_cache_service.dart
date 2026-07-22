import 'package:hive_flutter/hive_flutter.dart';

class HiveCacheService {
  static const String timetableCacheBox = 'timetable_cache_box';
  static const String userAuthBox = 'user_auth_box';
  static const String settingsBox = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(timetableCacheBox);
    await Hive.openBox(userAuthBox);
    await Hive.openBox(settingsBox);
  }

  static Box getBox(String boxName) => Hive.box(boxName);

  static Future<void> cacheData(String boxName, String key, dynamic value) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  static dynamic getCachedData(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.get(key);
  }
}
