import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'html_storage.dart' if (dart.library.io) 'io_storage.dart';

part 'micro_task.dart';

class LiteStorage {
  static final Map<String, LiteStorage> _sync = {};
  late Future<LiteStorage> _initStorage;
  Map<String, dynamic>? _initialData;

  factory LiteStorage([String container = 'LiteStorage', String? path, Map<String, dynamic>? initialData]) {
    if (_sync.containsKey(container)) {
      return _sync[container]!;
    } else {
      final instance = LiteStorage._internal(container, path, initialData);
      _sync[container] = instance;
      return instance;
    }
  }

  LiteStorage._internal(String key, [String? path, Map<String, dynamic>? initialData]) {
    Storage(key);
    _initialData = initialData;

    _initStorage = Future<LiteStorage>(() async {
      await _init();
      return this;
    });
  }

  Future<void> _init() async {
    try {
      await Storage.init(_initialData);
    } catch (err) {
      rethrow;
    }
  }

  static Future<LiteStorage> init([String container = 'LiteStorage']) {
    WidgetsFlutterBinding.ensureInitialized();
    return LiteStorage(container)._initStorage;
  }

  static T? read<T>(String key) => Storage.read(key);
  static void write(String key, dynamic value) {
    Storage.write(key, value);
    return _tryFlush();
  }

  static void remove(String key) {
    Storage.remove(key);
    return _tryFlush();
  }

  static void erase() {
    Storage.clear();
    return _tryFlush();
  }

  static void _tryFlush() => _MicroTask.exec(_addToQueue);

  static Future<void> _addToQueue() async => await _flush();

  static Future<void> _flush() async {
    try {
      await Storage.flush();
    } catch (e) {
      rethrow;
    }
    return;
  }
}
