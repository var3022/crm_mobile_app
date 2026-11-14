import 'package:web/web.dart' as web;
import 'crm_storage_adapter.dart';

/// Durable browser storage adapter using HTML5 localStorage across reloads.
class WebStorageAdapter implements StorageAdapter {
  static const _prefix = 'crm_pro_v1_';

  @override
  Future<String?> read(String key) async {
    try {
      return web.window.localStorage.getItem('$_prefix$key');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      web.window.localStorage.setItem('$_prefix$key', value);
    } catch (e) {
      throw StateError(
        'Browser localStorage write failed (quota exceeded or storage restricted): $e',
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      web.window.localStorage.removeItem('$_prefix$key');
    } catch (_) {}
  }

  @override
  Future<void> flush() async {}
}

StorageAdapter createStorageAdapter() => WebStorageAdapter();
