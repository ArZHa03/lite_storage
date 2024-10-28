import 'dart:async';

import 'package:flutter/widgets.dart';

import 'storage/io.dart';

class LiteStorage {
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
    _concrete = IOStorage(key, path);
    _initialData = initialData;

    initStorage = Future<bool>(() async {
      await _init();
      return true;
    });
  }

  static final Map<String, LiteStorage> _sync = {};

  final microtask = _Microtask();

  static Future<bool> init([String container = 'LiteStorage']) {
    WidgetsFlutterBinding.ensureInitialized();
    return LiteStorage(container).initStorage;
  }

  Future<void> _init() async {
    try {
      await _concrete.init(_initialData);
    } catch (err) {
      rethrow;
    }
  }

  T? read<T>(String key) => _concrete.read(key);
  T getKeys<T>() => _concrete.getKeys();
  T getValues<T>() => _concrete.getValues();
  bool hasData(String key) => (read(key) == null ? false : true);

  Map<String, dynamic> get changes => _concrete.subject;

  Future<void> write(String key, dynamic value) async {
    writeInMemory(key, value);

    return _tryFlush();
  }

  void writeInMemory(String key, dynamic value) {
    _concrete.write(key, value);
  }

  Future<void> writeIfNull(String key, dynamic value) async {
    if (read(key) != null) return;
    return write(key, value);
  }

  Future<void> remove(String key) async {
    _concrete.remove(key);
    return _tryFlush();
  }

  Future<void> erase() async {
    _concrete.clear();
    return _tryFlush();
  }

  Future<void> save() async => _tryFlush();

  Future<void> _tryFlush() async => microtask.exec(_addToQueue);

  Future _addToQueue() => _flush();

  Future<void> _flush() async {
    try {
      await _concrete.flush();
    } catch (e) {
      rethrow;
    }
    return;
  }

  late IOStorage _concrete;

  Map<String, dynamic> get listenable => _concrete.subject;

  late Future<bool> initStorage;

  Map<String, dynamic>? _initialData;
}

class _Microtask {
  int _version = 0;
  int _microtask = 0;

  void exec(Function callback) {
    if (_microtask == _version) {
      _microtask++;
      scheduleMicrotask(() {
        _version++;
        _microtask = _version;
        callback();
      });
    }
  }
}

typedef KeyCallback = Function(String);
