part of 'lite_storage.dart';

class _MicroTask {
  int _version = 0;
  int _microTask = 0;

  void exec(Function callback) {
    if (_microTask == _version) {
      _microTask++;
      scheduleMicrotask(() {
        _version++;
        _microTask = _version;
        callback();
      });
    }
  }
}
