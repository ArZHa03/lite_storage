part of 'lite_storage.dart';

abstract class _IStorage {
  Future<void> init([Map<String, dynamic>? initialData]);
  T? read<T>(String key);
  void write(String key, dynamic value);
  void remove(String key);
  void clear();
  Future<void> flush();
}
