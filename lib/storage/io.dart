import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class IOStorage {
  IOStorage(this.fileName, [this.path]);

  final String? path;
  final String fileName;

  Map<String, dynamic> subject = <String, dynamic>{};

  RandomAccessFile? _randomAccessfile;

  void clear() async => subject.clear();

  Future<void> deleteBox() async {
    final box = await _fileDb(isBackup: false);
    final backup = await _fileDb(isBackup: true);
    await Future.wait([box.delete(), backup.delete()]);
  }

  Future<void> flush() async {
    final buffer = utf8.encode(json.encode(subject));
    final length = buffer.length;
    RandomAccessFile file = await _getRandomFile();

    _randomAccessfile = await file.lock();
    _randomAccessfile = await _randomAccessfile!.setPosition(0);
    _randomAccessfile = await _randomAccessfile!.writeFrom(buffer);
    _randomAccessfile = await _randomAccessfile!.truncate(length);
    _randomAccessfile = await file.unlock();
    _madeBackup();
  }

  void _madeBackup() {
    _getFile(true).then((value) => value.writeAsString(json.encode(subject), flush: true));
  }

  T? read<T>(String key) => subject[key] as T?;

  T getKeys<T>() => subject.keys as T;

  T getValues<T>() => subject.values as T;

  Future<void> init([Map<String, dynamic>? initialData]) async {
    subject = initialData ?? <String, dynamic>{};

    RandomAccessFile file = await _getRandomFile();
    return file.lengthSync() == 0 ? flush() : _readFile();
  }

  void remove(String key) => subject.remove(key);

  void write(String key, dynamic value) => subject[key] = value;

  Future<void> _readFile() async {
    try {
      RandomAccessFile file = await _getRandomFile();
      file = await file.setPosition(0);
      final buffer = Uint8List(await file.length());
      await file.readInto(buffer);
      subject = json.decode(utf8.decode(buffer));
    } catch (e) {
      final file = await _getFile(true);

      final content = await file.readAsString()
        ..trim();

      if (content.isEmpty) {
        subject = {};
      } else {
        try {
          subject = (json.decode(content) as Map<String, dynamic>?) ?? {};
        } catch (e) {
          subject = {};
        }
      }
      flush();
    }
  }

  Future<RandomAccessFile> _getRandomFile() async {
    if (_randomAccessfile != null) return _randomAccessfile!;
    final fileDb = await _getFile(false);
    _randomAccessfile = await fileDb.open(mode: FileMode.append);

    return _randomAccessfile!;
  }

  Future<File> _getFile(bool isBackup) async {
    final fileDb = await _fileDb(isBackup: isBackup);
    if (!fileDb.existsSync()) fileDb.createSync(recursive: true);

    return fileDb;
  }

  Future<File> _fileDb({required bool isBackup}) async {
    final dir = await _getImplicitDir();
    final path = await _getPath(isBackup, dir.path);
    final file = File(path);
    return file;
  }

  Future<Directory> _getImplicitDir() async {
    try {
      return getApplicationDocumentsDirectory();
    } catch (err) {
      rethrow;
    }
  }

  Future<String> _getPath(bool isBackup, String? path) async {
    final isWindows = Platform.isWindows;
    final separator = isWindows ? '\\' : '/';
    return isBackup ? '$path$separator$fileName.bak' : '$path$separator$fileName.gs';
  }
}
