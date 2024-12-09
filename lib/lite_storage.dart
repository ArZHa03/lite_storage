import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

part 'io_storage.dart';
part 'microtask.dart';

class LiteStorage {
  static final Map<String, LiteStorage> _sync = {};
  final _microtask = _Microtask();
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
    _IoStorage(key);
    _initialData = initialData;

    _initStorage = Future<LiteStorage>(() async {
      await _init();
      return this;
    });
  }

  Future<void> _init() async {
    try {
      await _IoStorage.init(_initialData);
    } catch (err) {
      rethrow;
    }
  }

  static Future<LiteStorage> init([String container = 'LiteStorage']) {
    WidgetsFlutterBinding.ensureInitialized();
    return LiteStorage(container)._initStorage;
  }

  static T? read<T>(String key) => _IoStorage.read(key);

  void write(String key, dynamic value) {
    _IoStorage.write(key, value);
    return _tryFlush();
  }

  void insertAtBeginning(String key, dynamic value) {
    dynamic existingData = _IoStorage.read(key);

    if (existingData is Map && existingData.containsKey('data') && existingData['data'] is List) {
      existingData['data'].insert(0, value);
    } else {
      existingData = {
        'data': [value]
      };
    }

    _IoStorage.write(key, existingData);
    return _tryFlush();
  }

  void remove(String key) {
    _IoStorage.remove(key);
    return _tryFlush();
  }

  void erase() {
    _IoStorage.clear();
    return _tryFlush();
  }

  void _tryFlush() => _microtask.exec(_addToQueue);

  Future<void> _addToQueue() async => await _flush();

  Future<void> _flush() async {
    try {
      await _IoStorage._flush();
    } catch (e) {
      rethrow;
    }
    return;
  }
}
