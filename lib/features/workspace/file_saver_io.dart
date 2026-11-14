import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Native file saver that writes bytes to user Downloads or app documents directory.
Future<String?> saveFileBytes({
  required String filename,
  required List<int> bytes,
  required String mimeType,
}) async {
  Directory? targetDir;
  try {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final home =
          Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
      if (home != null) {
        final dl = Directory('$home/Downloads');
        if (dl.existsSync()) targetDir = dl;
      }
    }
    targetDir ??=
        await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
  } catch (_) {
    targetDir = Directory.systemTemp;
  }

  try {
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }
    final file = File('${targetDir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  } catch (e) {
    return null;
  }
}
