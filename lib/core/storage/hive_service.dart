import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();

  HiveService._internal();

  factory HiveService() {
    return _instance;
  }

  Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<Box<T>> openBox<T>(String boxName) => Hive.openBox<T>(boxName);

  Future<void> closeBox(String boxName) async {
    final box = Hive.box(boxName);
    await box.close();
  }

  Future<void> closeAllBoxes() => Hive.close();

  Future<void> clearBox(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  Future<void> deleteBox(String boxName) => Hive.deleteBoxFromDisk(boxName);
}
