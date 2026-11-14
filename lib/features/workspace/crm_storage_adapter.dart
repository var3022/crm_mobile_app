abstract class StorageAdapter {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> flush() async {}
}

/// In-memory storage adapter for testing and isolated sandboxed execution.
class MemoryStorageAdapter implements StorageAdapter {
  MemoryStorageAdapter([Map<String, String>? initialData])
    : _data = initialData != null ? Map.from(initialData) : {};

  final Map<String, String> _data;
  int writeCount = 0;
  int readCount = 0;

  Map<String, String> get snapshot => Map.unmodifiable(_data);

  @override
  Future<String?> read(String key) async {
    readCount++;
    return _data[key];
  }

  @override
  Future<void> write(String key, String value) async {
    writeCount++;
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> flush() async {}
}

StorageAdapter createStorageAdapter() => throw UnsupportedError(
  'Cannot create a storage adapter without dart:io or dart:html/package:web',
);
