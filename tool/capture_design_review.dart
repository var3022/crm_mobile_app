import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_pro/main.dart';
import '../test/font_setup.dart';

/// Run explicitly with flutter test tool/capture_design_review.dart.
/// Captures actual app widgets for visual comparison with the reference PDF.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppTestFont);
  testWidgets('capture reference review screens', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key: boundaryKey, child: const CrmProApp()));
    await tester.pump(const Duration(seconds: 1));
    final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
    const routes = ['dashboard','leads','customers','lead-details','customer-details','pipeline','visits','active-visit','tasks','reports','profile','settings','targets','offline-data'];
    final output = Directory('../tmp/pdfs/app-review');
    output.createSync(recursive:true);
    for (final route in routes) {
      navigator.pushNamedAndRemoveUntil('/$route', (_) => false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();
      await tester.runAsync(() async {
        final boundary = boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final frame = await boundary.toImage(pixelRatio: 2);
        final bytes = await frame.toByteData(format: ui.ImageByteFormat.png);
        await File('${output.path}/$route.png').writeAsBytes(bytes!.buffer.asUint8List());
        frame.dispose();
      });
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
