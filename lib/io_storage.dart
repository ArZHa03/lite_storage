import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

@protected
class Storage {
  final String _fileName;
  Map<String, dynamic> _subject = <String, dynamic>{};
  RandomAccessFile? _randomAccessFile;

  Storage(this._fileName);

  Future<void> init([Map<String, dynamic>? initialData]) async {
    _subject = initialData ?? <String, dynamic>{};

    RandomAccessFile file = await _getRandomFile();
    return file.lengthSync() == 0 ? flush() : _readFile();
  }

  T? read<T>(String key) => _subject[key] as T?;
  void write(String key, dynamic value) => _subject[key] = value;
  void remove(String key) => _subject.remove(key);
  void clear() async => _subject.clear();

  Future<void> flush() async {
    final buffer = utf8.encode(json.encode(_subject));
    final length = buffer.length;
    RandomAccessFile file = await _getRandomFile();

    _randomAccessFile = await file.lock();
    _randomAccessFile = await _randomAccessFile!.setPosition(0);
    _randomAccessFile = await _randomAccessFile!.writeFrom(buffer);
    _randomAccessFile = await _randomAccessFile!.truncate(length);
    _randomAccessFile = await file.unlock();
    _madeBackup();
  }

  void _madeBackup() => _getFile(true).then((value) => value.writeAsString(json.encode(_subject), flush: true));

  Future<void> _readFile() async {
    try {
      RandomAccessFile file = await _getRandomFile();
      file = await file.setPosition(0);
      final buffer = Uint8List(await file.length());
      await file.readInto(buffer);
      _subject = json.decode(utf8.decode(buffer));
    } catch (e) {
      final file = await _getFile(true);

      final content = await file.readAsString()
        ..trim();

      if (content.isEmpty) {
        _subject = {};
      } else {
        try {
          _subject = (json.decode(content) as Map<String, dynamic>?) ?? {};
        } catch (e) {
          _subject = {};
        }
      }
      flush();
    }
  }

  Future<RandomAccessFile> _getRandomFile() async {
    if (_randomAccessFile != null) return _randomAccessFile!;
    final fileDb = await _getFile(false);
    _randomAccessFile = await fileDb.open(mode: FileMode.append);

    return _randomAccessFile!;
  }

  Future<File> _getFile(bool isBackup) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = await _getPath(isBackup, dir.path);
    final file = File(path);
    if (!file.existsSync()) file.createSync(recursive: true);
    return file;
  }

  Future<String> _getPath(bool isBackup, String? path) async {
    final isWindows = Platform.isWindows;
    final separator = isWindows ? '\\' : '/';
    return isBackup ? '$path$separator$_fileName.bak' : '$path$separator$_fileName.gs';
  }
}
