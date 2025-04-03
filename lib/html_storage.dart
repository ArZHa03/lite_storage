import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/cupertino.dart';

@protected
class Storage {
  final String _fileName;
  final _ValueStorage<Map<String, dynamic>> _subject = _ValueStorage<Map<String, dynamic>>(<String, dynamic>{});
  late Future<String> Function(String) _encrypt;
  late Future<String> Function(String) _decrypt;

  Storage(this._fileName);

  Future<void> init(Map<String, dynamic>? initialData, Future<String> Function(String) encrypt, Future<String> Function(String) decrypt) async {
    _encrypt = encrypt;
    _decrypt = decrypt;
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
  html.Storage get _localStorage => html.window.localStorage;
  Future<bool> _exists() async => _localStorage.containsKey(_fileName);
  Future<void> _writeToStorage(Map<String, dynamic> data) async {
    final dataValue = await _encrypt(json.encode(data));
    final subjectValue = await _encrypt(json.encode(_subject.value));
    _localStorage.update(_fileName, (val) => dataValue, ifAbsent: () => subjectValue);
  }

  Future<void> _readFromStorage() async {
    final dataFromLocal = _localStorage.entries.firstWhereOrNull((value) => value.key == _fileName);
    if (dataFromLocal == null) return await _writeToStorage(<String, dynamic>{});
    _subject.value = json.decode(await _decrypt(dataFromLocal.value)) as Map<String, dynamic>;
  }
}

extension FirstWhereExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class _ValueStorage<T> extends ValueNotifier<T> {
  _ValueStorage(super.value);
}
