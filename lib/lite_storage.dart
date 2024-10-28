import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'i_lite_storage.dart';

part 'io_storage.dart';

class LiteStorage implements ILiteStorage {
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

  static final Map<String, LiteStorage> _sync = {};

  final microtask = _Microtask();

  static Future<LiteStorage> init([String container = 'LiteStorage']) {
    WidgetsFlutterBinding.ensureInitialized();
    return LiteStorage(container)._initStorage;
  }

  Future<void> _init() async {
    try {
      await _concrete._init(_initialData);
    } catch (err) {
      rethrow;
    }
  }

  @override
  T? read<T>(String key) => _concrete._read(key);

  @override
  void write(String key, dynamic value) {
    _concrete._write(key, value);
    return _tryFlush();
  }

  @override
  void remove(String key) {
    _concrete._remove(key);
    return _tryFlush();
  }

  @override
  void erase() {
    _concrete._clear();
    return _tryFlush();
  }

  void _tryFlush() => microtask._exec(_addToQueue);

  Future<void> _addToQueue() async => await _flush();

  Future<void> _flush() async {
    try {
      await _concrete._flush();
    } catch (e) {
      rethrow;
    }
    return;
  }

  late _IoStorage _concrete;

  late Future<LiteStorage> _initStorage;

  Map<String, dynamic>? _initialData;
}

class _Microtask {
  int _version = 0;
  int _microtask = 0;

  void _exec(Function callback) {
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
