abstract class ILiteStorage {
  T? read<T>(String key);

  void write(String key, dynamic value);

  void remove(String key);

  void erase();
}
