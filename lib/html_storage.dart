import 'dart:convert' show json;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show protected, ValueNotifier;

@protected
class Storage {
  static Storage? _instance;
  static late String _fileName;
  static final _ValueStorage<Map<String, dynamic>> _subject = _ValueStorage<Map<String, dynamic>>(<String, dynamic>{});

  factory Storage(String fileName) {
    _instance ??= Storage._internal(fileName);
    return _instance!;
  }

  Storage._internal(String fileName) {
    _fileName = fileName;
  }

  Future<void> init([Map<String, dynamic>? initialData]) async {
    _subject.value = initialData ?? <String, dynamic>{};
    if (await _exists()) return await _readFromStorage();
    return await _writeToStorage(_subject.value);
  }

  T? read<T>(String key) => _subject.value[key] as T?;

  void remove(String key) => _subject.value.remove(key);

  void write(String key, dynamic value) => _subject.value[key] = value;

  void clear() {
    _localStorage.remove(_fileName);
    _subject.value.clear();
  }

  Future<void> flush() => _writeToStorage(_subject.value);

  static html.Storage get _localStorage => html.window.localStorage;
  static Future<bool> _exists() async => _localStorage.containsKey(_fileName);
  static Future<void> _writeToStorage(Map<String, dynamic> data) async =>
      _localStorage.update(_fileName, (val) => json.encode(data), ifAbsent: () => json.encode(_subject.value));
  static Future<void> _readFromStorage() async {
    final dataFromLocal = _localStorage.entries._firstWhereOrNull((value) => value.key == _fileName);
    if (dataFromLocal == null) return await _writeToStorage(<String, dynamic>{});
    _subject.value = json.decode(dataFromLocal.value) as Map<String, dynamic>;
  }
}

extension _FirstWhereExt<T> on Iterable<T> {
  T? _firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class _ValueStorage<T> extends ValueNotifier<T> {
  _ValueStorage(super.value);
}
