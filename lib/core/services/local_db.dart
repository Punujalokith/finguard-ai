import 'package:hive_flutter/hive_flutter.dart';

class LocalDb {
  static const String _transactionsBox = 'transactions';
  static const String _goalsBox = 'goals';
  static const String _userBox = 'user';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(_transactionsBox);
    await Hive.openBox<dynamic>(_goalsBox);
    await Hive.openBox<dynamic>(_userBox);
  }

  static Box<dynamic> get transactions => Hive.box<dynamic>(_transactionsBox);
  static Box<dynamic> get goals => Hive.box<dynamic>(_goalsBox);
  static Box<dynamic> get user => Hive.box<dynamic>(_userBox);
}
