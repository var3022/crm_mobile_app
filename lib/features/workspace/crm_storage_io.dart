import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'crm_storage_adapter.dart';

/// Durable native filesystem storage adapter using crash-safe staging,
/// atomic replacements, backup recovery, and write queue failure isolation.
class IoStorageAdapter implements StorageAdapter {
  IoStorageAdapter({Directory? customDirectory})
    : _overrideDir = customDirectory;

  final Directory? _overrideDir;
  Directory? _dir;
  Future<void> _writeQueue = Future.value();

  Future<Directory> _resolveDir() async {
    if (_overrideDir != null) return _overrideDir;
    if (_dir != null) return _dir!;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final docs = await getApplicationDocumentsDirectory();
        final target = Directory('${docs.path}/crm_pro_sales');
        if (!target.existsSync()) {
          target.createSync(recursive: true);
        }
        _dir = target;
        return _dir!;
      }

      String? basePath;
      if (Platform.isWindows) {
        basePath =
            Platform.environment['LOCALAPPDATA'] ??
            Platform.environment['APPDATA'] ??
            Platform.environment['USERPROFILE'];
      } else if (Platform.isMacOS) {
        final home = Platform.environment['HOME'];
        if (home != null) basePath = '$home/Library/Application Support';
      } else if (Platform.isLinux) {
        basePath =
            Platform.environment['XDG_DATA_HOME'] ??
            (Platform.environment['HOME'] != null
                ? '${Platform.environment['HOME']}/.local/share'
                : null);
      }

      basePath ??= Directory.systemTemp.path;
      final target = Directory('$basePath/crm_pro_sales');
      if (!target.existsSync()) {
        target.createSync(recursive: true);
      }
      _dir = target;
    } catch (_) {
      _dir = Directory.systemTemp;
    }
    return _dir!;
  }

  Future<File> _file(String key) async {
    final d = await _resolveDir();
    return File('${d.path}/$key.json');
  }

  @override
  Future<String?> read(String key) async {
    try {
      final f = await _file(key);
      if (await f.exists()) {
        return await f.readAsString();
      }

      // Automatic crash recovery: check if a .bak file exists from an interrupted replacement
      final bak = File('${f.path}.bak');
      if (await bak.exists()) {
        await bak.rename(f.path);
        return await f.readAsString();
      }
    } catch (e) {
      final f = await _file(key);
      throw FileSystemException(
        'Failed to read storage key "$key"',
        f.path,
        OSError('$e'),
      );
    }
    return null;
  }

  Future<void> _performCrashSafeAtomicWrite(String key, String value) async {
    final target = await _file(key);
    final tmp = File('${target.path}.tmp');
    final bak = File('${target.path}.bak');

    try {
      // Step 1: Write to staging file with flush
      await tmp.writeAsString(value, flush: true);

      // Step 2: Crash-safe backup staging
      if (await target.exists()) {
        if (await bak.exists()) {
          await bak.delete();
        }
        await target.rename(bak.path);
      }

      // Step 3: Atomic rename from tmp to target
      try {
        await tmp.rename(target.path);
        // Step 4: Remove backup once target rename is verified
        if (await bak.exists()) {
          await bak.delete();
        }
      } catch (renameErr) {
        // Recovery: if target rename failed, restore target from backup
        if (!await target.exists() && await bak.exists()) {
          await bak.rename(target.path);
        }
        rethrow;
      }
    } catch (e) {
      if (await tmp.exists()) {
        try {
          await tmp.delete();
        } catch (_) {}
      }
      throw FileSystemException(
        'Crash-safe atomic write failed for key "$key"',
        target.path,
        OSError('$e'),
      );
    }
  }

  @override
  Future<void> write(String key, String value) {
    // Chain onto the write queue using whenComplete so individual errors do not halt the queue
    final completer = Completer<void>();
    _writeQueue = _writeQueue.whenComplete(() async {
      try {
        await _performCrashSafeAtomicWrite(key, value);
        completer.complete();
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  @override
  Future<void> delete(String key) async {
    try {
      final f = await _file(key);
      if (await f.exists()) await f.delete();
      final tmp = File('${f.path}.tmp');
      if (await tmp.exists()) await tmp.delete();
      final bak = File('${f.path}.bak');
      if (await bak.exists()) await bak.delete();
    } catch (_) {}
  }

  @override
  Future<void> flush() async {
    await _writeQueue;
  }
}

StorageAdapter createStorageAdapter() => IoStorageAdapter();
