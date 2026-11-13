import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> loadAppTestFont() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  final loader = FontLoader('Inter');
  loader.addFont(rootBundle.load('assets/fonts/Inter.ttf'));
  await loader.load();
}
