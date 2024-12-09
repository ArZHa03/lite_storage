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

  static void write(String key, dynamic value) {
    _IoStorage.write(key, value);
    return _tryFlush();
  }

  static void insertAtBeginning(String key, dynamic value, {dynamic id}) {
    dynamic existingData = _IoStorage.read(key);

    if (existingData is Map && existingData.containsKey('data') && existingData['data'] is List) {
      if (id != null) {
        final index = existingData['data'].indexWhere((element) => element['id'] == id);
        if (index != -1) {
          existingData['data'][index] = value;
          final updatedElement = existingData['data'].removeAt(index);
          existingData['data'].insert(0, updatedElement);
        }
      } else {
        existingData['data'].insert(0, value);
      }
    } else {
      existingData = {
        'data': [value]
      };
    }

    _IoStorage.write(key, existingData);
    return _tryFlush();
  }

  static void update(String key, dynamic value, dynamic id) {
    dynamic existingData = _IoStorage.read(key);

    if (existingData is Map && existingData.containsKey('data') && existingData['data'] is List) {
      final index = existingData['data'].indexWhere((element) => element['id'] == id);
      if (index != -1) {
        existingData['data'][index] = value;
        final updatedElement = existingData['data'].removeAt(index);
        existingData['data'].insert(0, updatedElement);
      }
    }

    _IoStorage.write(key, existingData);
    return _tryFlush();
  }

  static void remove(String key) {
    _IoStorage.remove(key);
    return _tryFlush();
  }

  static void erase() {
    _IoStorage.clear();
    return _tryFlush();
  }

  static void _tryFlush() => _Microtask.exec(_addToQueue);

  static Future<void> _addToQueue() async => await _flush();

  static Future<void> _flush() async {
    try {
      await _IoStorage._flush();
    } catch (e) {
      rethrow;
    }
    return;
  }
}
