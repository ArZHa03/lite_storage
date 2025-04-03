import 'dart:async';

import 'package:flutter/material.dart';

import 'html_storage.dart' if (dart.library.io) 'io_storage.dart';
import 'i_lite_storage.dart';

part 'micro_task.dart';

class LiteStorage implements ILiteStorage {
  final _microTask = _MicroTask();
  static final Map<String, LiteStorage> _sync = {};
  late Storage _concrete;
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
    _concrete = Storage(key);
    _initialData = initialData;

    _initStorage = Future<LiteStorage>(() async {
      await _init();
      return this;
    });
  }

  Future<void> _init() async {
    try {
      await _concrete.init(_initialData);
    } catch (err) {
      rethrow;
    }
  }

  static Future<LiteStorage> init([String container = 'LiteStorage']) {
    WidgetsFlutterBinding.ensureInitialized();
    return LiteStorage(container)._initStorage;
  }

  @override
  T? read<T>(String key) => _concrete.read(key);
  @override
  void write(String key, dynamic value) {
    _concrete.write(key, value);
    return _tryFlush();
  }

  @override
  void remove(String key) {
    _concrete.remove(key);
    return _tryFlush();
  }

  @override
  void erase() {
    _concrete.clear();
    return _tryFlush();
  }

  void _tryFlush() => _microTask.exec(_addToQueue);

  Future<void> _addToQueue() async => await _flush();

  Future<void> _flush() async {
    try {
      await _concrete.flush();
    } catch (e) {
      rethrow;
    }
    return;
  }
}
