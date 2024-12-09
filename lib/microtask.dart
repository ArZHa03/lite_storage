part of 'lite_storage.dart';

class _Microtask {
  static _Microtask? _instance;
  factory _Microtask() {
    _instance ??= _Microtask._internal();
    return _instance!;
  }
  _Microtask._internal();

  static int _version = 0;
  static int _microtask = 0;

  static void exec(Function callback) {
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
