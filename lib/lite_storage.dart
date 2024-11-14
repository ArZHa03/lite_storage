import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'i_lite_storage.dart';

part 'io_storage.dart';
part 'microtask.dart';

class LiteStorage implements ILiteStorage {
  static final Map<String, LiteStorage> _sync = {};
  final _microtask = _Microtask();
  late _IoStorage _concrete;
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
    _concrete = _IoStorage(key);
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

  void _tryFlush() => _microtask.exec(_addToQueue);

  Future<void> _addToQueue() async => await _flush();

  Future<void> _flush() async {
    try {
      await _concrete._flush();
    } catch (e) {
      rethrow;
    }
    return;
  }
}
