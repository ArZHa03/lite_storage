import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

part 'html_storage.dart';
part 'i_storage.dart';
part 'io_storage.dart';
part 'micro_task.dart';

class LiteStorage {
  static final Map<String, LiteStorage> _sync = {};
  static late _IStorage _storage;

  static bool _isInit = false;

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
    _storage = kIsWeb ? _HTMLStorage(key) : _IOStorage(key);
    _initialData = initialData;

    _initStorage = Future<LiteStorage>(() async {
      await _init();
      return this;
    });
  }

  Future<void> _init() async {
    try {
      await _storage.init(_initialData);
      _isInit = true;
    } catch (err) {
      rethrow;
    }
  }

  static Future<LiteStorage> init([String container = 'LiteStorage']) {
    WidgetsFlutterBinding.ensureInitialized();
    return LiteStorage(container)._initStorage;
  }

  static dynamic read<T>(String key) => _isInit ? _storage.read(key) : _log();
  static void write(String key, dynamic value) {
    if (!_isInit) return _log();
    _storage.write(key, value);
    return _tryFlush();
  }

  static void remove(String key) {
    if (!_isInit) return _log();
    _storage.remove(key);
    return _tryFlush();
  }

  static void erase() {
    if (!_isInit) return _log();
    _storage.clear();
    return _tryFlush();
  }

  static void _tryFlush() => _MicroTask.exec(_addToQueue);

  static Future<void> _addToQueue() async => await _flush();

  static Future<void> _flush() async {
    try {
      await _storage.flush();
    } catch (e) {
      rethrow;
    }
    return;
  }

  static void _log() => log(name: 'LiteStorage', 'LiteStorage need to be initialized');
}
