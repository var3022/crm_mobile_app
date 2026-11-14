import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

/// Browser file saver that triggers real browser downloads and object URL cleanup.
Future<String?> saveFileBytes({
  required String filename,
  required List<int> bytes,
  required String mimeType,
}) async {
  try {
    final uint8List = Uint8List.fromList(bytes);
    final blob = web.Blob(
      [uint8List.toJS].toJS,
      web.BlobPropertyBag(type: mimeType),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = filename;
    anchor.style.display = 'none';
    web.document.body?.appendChild(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
    return filename;
  } catch (e) {
    return null;
  }
}
