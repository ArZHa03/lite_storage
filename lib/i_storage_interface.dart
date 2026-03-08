abstract class IStorage {
  Future<void> init([Map<String, dynamic>? initialData]);
  T? read<T>(String key);
  void write(String key, dynamic value);
  void remove(String key);
  void clear();
  Future<void> flush();
}
