part of 'lite_storage.dart';

class _HTMLStorage implements _IStorage {
  static _HTMLStorage? _instance;
  static late String _fileName;
  static final _ValueStorage<Map<String, dynamic>> _subject = _ValueStorage<Map<String, dynamic>>(<String, dynamic>{});

  factory _HTMLStorage(String fileName) {
    _instance ??= _HTMLStorage._internal(fileName);
    return _instance!;
  }

  _HTMLStorage._internal(String fileName) {
    _fileName = fileName;
  }

  @override
  Future<void> init([Map<String, dynamic>? initialData]) async {
    _subject.value = initialData ?? <String, dynamic>{};
    if (await _exists()) return await _readFromStorage();
    return await _writeToStorage(_subject.value);
  }

  @override
  T? read<T>(String key) => _subject.value[key] as T?;

  @override
  void remove(String key) => _subject.value.remove(key);

  @override
  void write(String key, dynamic value) => _subject.value[key] = value;

  @override
  void clear() {
    _localStorage.removeItem(_fileName);
    _subject.value.clear();
  }

  @override
  Future<void> flush() => _writeToStorage(_subject.value);

  static web.Storage get _localStorage => web.window.localStorage;

  static Future<bool> _exists() async => _localStorage.getItem(_fileName) != null;

  static Future<void> _writeToStorage(Map<String, dynamic> data) async {
    final dataValue = json.encode(data);
    _localStorage.setItem(_fileName, dataValue);
  }

  static Future<void> _readFromStorage() async {
    final dataFromLocal = _localStorage.getItem(_fileName);
    if (dataFromLocal == null) return await _writeToStorage(<String, dynamic>{});
    _subject.value = json.decode(dataFromLocal) as Map<String, dynamic>;
  }
}

class _ValueStorage<T> extends ValueNotifier<T> {
  _ValueStorage(super.value);
}
