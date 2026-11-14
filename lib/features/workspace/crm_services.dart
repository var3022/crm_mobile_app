import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

typedef PlatformLauncher = Future<bool> Function(Uri uri);

/// Platform handoffs, external URL intents, and service boundary management.
class DeviceService {
  /// Optional injected launcher (for tests and native platform channel overrides).
  static PlatformLauncher? customLauncher;

  /// Audit log of all URIs dispatched to the platform launcher.
  static final List<Uri> launchedUris = [];

  /// Clears the audit log (useful between test runs).
  static void clearAuditLog() => launchedUris.clear();

  /// Launches an external platform URI with fallback to clipboard.
  static Future<bool> launchUri(Uri uri) async {
    launchedUris.add(uri);
    if (customLauncher != null) {
      try {
        final ok = await customLauncher!(uri);
        if (ok) return true;
      } catch (_) {}
    }

    try {
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return true;
      }
    } catch (_) {}

    return false;
  }

  /// Initiates a phone call via `tel:` intent, falling back to clipboard if unsupported.
  static Future<void> callPhone(
    dynamic first, [
    dynamic second,
    dynamic third,
  ]) async {
    String phone = '';
    BuildContext? context;
    String? contactName;
    if (first is BuildContext) {
      context = first;
      if (second is String) phone = second;
      if (third is String) contactName = third;
    } else if (first is String) {
      phone = first;
      if (second is BuildContext) {
        context = second;
        if (third is String) contactName = third;
      } else if (second is String) {
        contactName = second;
        if (third is BuildContext) context = third;
      }
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    final launched = await launchUri(uri);

    try {
      await Clipboard.setData(ClipboardData(text: cleanPhone));
    } catch (_) {}

    if (context != null && context.mounted) {
      final msg = launched
          ? 'Initiating call to $phone (${contactName ?? "Contact"})...'
          : 'Dialer not available. Copied $phone (${contactName ?? "Contact"}) to clipboard.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    }
  }

  /// Opens email composer via `mailto:` intent with encoded subject and body.
  static Future<void> sendEmail(
    dynamic first, [
    dynamic second,
    dynamic third,
  ]) async {
    String email = '';
    String? subject;
    BuildContext? context;
    if (first is BuildContext) {
      context = first;
      if (second is String) email = second;
      if (third is String) subject = third;
    } else if (first is String) {
      email = first;
      if (second is String) {
        subject = second;
        if (third is BuildContext) context = third;
      } else if (second is BuildContext) {
        context = second;
      }
    }

    final uri = Uri(
      scheme: 'mailto',
      path: email.trim(),
      queryParameters: subject != null && subject.isNotEmpty
          ? {'subject': subject}
          : null,
    );
    final launched = await launchUri(uri);

    try {
      await Clipboard.setData(ClipboardData(text: email.trim()));
    } catch (_) {}

    if (context != null && context.mounted) {
      final msg = launched
          ? 'Opening mail composer for $email...'
          : 'Mail composer not available. Copied $email to clipboard.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    }
  }

  /// Opens WhatsApp via `https://wa.me/` intent with URL-encoded message.
  static Future<void> sendWhatsApp(
    dynamic first, [
    dynamic second,
    dynamic third,
  ]) async {
    String phone = '';
    String? message;
    BuildContext? context;
    if (first is BuildContext) {
      context = first;
      if (second is String) phone = second;
      if (third is String) message = third;
    } else if (first is String) {
      phone = first;
      if (second is String) {
        message = second;
        if (third is BuildContext) context = third;
      } else if (second is BuildContext) {
        context = second;
      }
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.https(
      'wa.me',
      '/$cleanPhone',
      (message != null && message.isNotEmpty) ? {'text': message} : null,
    );
    final launched = await launchUri(uri);

    try {
      await Clipboard.setData(ClipboardData(text: phone));
    } catch (_) {}

    if (context != null && context.mounted) {
      final msg = launched
          ? 'Opening WhatsApp for $phone...'
          : 'WhatsApp app not available. Copied $phone to clipboard.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    }
  }

  /// Opens Google Maps / Apple Maps directions intent.
  static Future<void> getDirections(dynamic first, [dynamic second]) async {
    String address = '';
    BuildContext? context;
    if (first is BuildContext) {
      context = first;
      if (second is String) address = second;
    } else if (first is String) {
      address = first;
      if (second is BuildContext) context = second;
    }

    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': address,
    });
    final launched = await launchUri(uri);

    try {
      await Clipboard.setData(ClipboardData(text: address));
    } catch (_) {}

    if (context != null && context.mounted) {
      final msg = launched
          ? 'Opening navigation directions to: $address'
          : 'Map navigation app not available. Address copied: $address';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  /// Shares content or falls back to clipboard.
  static Future<void> shareContent({
    dynamic context,
    String? title,
    required String text,
    String? subject,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (_) {}
    if (context is BuildContext && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Content copied to clipboard: ${title ?? "Shared"}'),
        ),
      );
    }
  }
}

/// Standards-compliant RFC 6238 TOTP authentication and backup code management.
class AuthService {
  static const base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  /// Decodes a standard Base32 encoded string into raw bytes.
  static Uint8List base32Decode(String input) {
    final clean = input
        .replaceAll('=', '')
        .replaceAll(RegExp(r'[\s\-]'), '')
        .toUpperCase();
    var buffer = 0;
    var bitsLeft = 0;
    final bytes = <int>[];
    for (var i = 0; i < clean.length; i++) {
      final val = base32Alphabet.indexOf(clean[i]);
      if (val < 0) continue;
      buffer = (buffer << 5) | val;
      bitsLeft += 5;
      if (bitsLeft >= 8) {
        bitsLeft -= 8;
        bytes.add((buffer >> bitsLeft) & 0xff);
      }
    }
    return Uint8List.fromList(bytes);
  }

  /// Computes an RFC 6238 6-digit TOTP token for the given secret and timestamp.
  static String generateTotp({
    required String secret,
    int? timestampSeconds,
    int timeStep = 30,
  }) {
    final keyBytes = base32Decode(secret);
    if (keyBytes.isEmpty) return '';
    final seconds =
        timestampSeconds ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final counter = seconds ~/ timeStep;

    final counterBytes = Uint8List(8);
    var temp = counter;
    for (var i = 7; i >= 0; i--) {
      counterBytes[i] = temp & 0xff;
      temp = temp >> 8;
    }

    final hmac = Hmac(sha1, keyBytes);
    final hash = hmac.convert(counterBytes).bytes;
    final offset = hash[19] & 0x0f;
    final binary =
        ((hash[offset] & 0x7f) << 24) |
        ((hash[offset + 1] & 0xff) << 16) |
        ((hash[offset + 2] & 0xff) << 8) |
        (hash[offset + 3] & 0xff);
    final token = binary % 1000000;
    return token.toString().padLeft(6, '0');
  }

  /// Validates a TOTP code against an RFC 6238 secret.
  /// Allows clock drift tolerance window of +/- [window] steps (default 1 = +/-30s).
  static bool verifyTotp({
    required String code,
    required String secret,
    int? currentTimestampSeconds,
    int timeStep = 30,
    int window = 1,
  }) {
    final cleanCode = code.replaceAll(RegExp(r'\s+'), '');
    if (cleanCode.length != 6 || int.tryParse(cleanCode) == null) {
      return false;
    }
    final keyBytes = base32Decode(secret);
    if (keyBytes.isEmpty) return false;

    final currentSec =
        currentTimestampSeconds ??
        (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final currentStep = currentSec ~/ timeStep;

    for (var w = -window; w <= window; w++) {
      final stepSec = (currentStep + w) * timeStep;
      final expected = generateTotp(
        secret: secret,
        timestampSeconds: stepSec,
        timeStep: timeStep,
      );
      if (expected == cleanCode) {
        return true;
      }
    }
    return false;
  }

  /// Public TOTP verification helper: strictly requires a valid secret.
  static bool verifyTotpCode(String code, [String? secret]) {
    if (secret == null || secret.trim().isEmpty) {
      return false; // Strictly reject missing or empty secrets
    }
    return verifyTotp(code: code, secret: secret);
  }

  /// Generates a cryptographically secure random Base32 secret for enrollment.
  static String generateRandomBase32Secret([int length = 16]) {
    final rand = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(base32Alphabet[rand.nextInt(base32Alphabet.length)]);
    }
    return buffer.toString();
  }

  /// Generates a set of unique 8-character emergency backup recovery codes.
  static List<String> generateBackupCodes([int count = 8]) {
    final rand = Random.secure();
    const chars = '0123456789ABCDEF';
    final codes = <String>{};
    while (codes.length < count) {
      final part1 = List.generate(
        4,
        (_) => chars[rand.nextInt(chars.length)],
      ).join();
      final part2 = List.generate(
        4,
        (_) => chars[rand.nextInt(chars.length)],
      ).join();
      codes.add('$part1 - $part2');
    }
    return codes.toList();
  }

  /// Normalizes a backup code by removing whitespace and hyphens.
  static String normalizeBackupCode(String code) {
    return code.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
  }

  /// Validates and consumes a one-time emergency backup code.
  /// If the code was already consumed or is invalid, returns false.
  /// If valid, removes from [availableCodes] and adds to [consumedCodes].
  static bool consumeBackupCode({
    required String code,
    required List<String> availableCodes,
    required List<String> consumedCodes,
  }) {
    final norm = normalizeBackupCode(code);
    if (norm.isEmpty) return false;

    // Check if already used
    if (consumedCodes.any((c) => normalizeBackupCode(c) == norm)) {
      return false; // Repeated backup code use rejected
    }

    final index = availableCodes.indexWhere(
      (c) => normalizeBackupCode(c) == norm,
    );
    if (index >= 0) {
      final matched = availableCodes.removeAt(index);
      consumedCodes.add(matched);
      return true;
    }
    return false;
  }

  /// Validates a backup code without mutating the collection.
  static bool verifyBackupCode(String code, List<String> availableCodes) {
    final norm = normalizeBackupCode(code);
    return availableCodes.any((c) => normalizeBackupCode(c) == norm);
  }
}

/// Simulated OCR service for business cards and documents.
class OcrService {
  /// True indicates this is a simulated local heuristic parser, not a connected cloud Vision API.
  static const bool isSimulated = true;

  static Future<String> extractCardText(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (category == 'Visiting Card') {
      return '[SIMULATED OCR PREVIEW]\n(Local heuristic parser - connect Google Cloud Vision / ML Kit for camera OCR)\n\n'
          'ALEX MORGAN\nChief Technology Officer\nAcme Corp\nPhone: +91 98765 43210\nEmail: alex.morgan@acme.com\nOffice: Nariman Point, Mumbai';
    }
    return '[SIMULATED OCR PREVIEW]\nSTORE FRONT VERIFICATION\nAcme Industries Outpost\nTimestamp: ${DateTime.now().toLocal()}\nSimulated GPS: Lat 18.922, Lng 72.834';
  }

  /// Extracts text from business card or document photo.
  static Future<String> extractTextFromImage(String assetOrPath) async {
    return extractCardText(
      assetOrPath.toLowerCase().contains('visiting')
          ? 'Visiting Card'
          : 'General',
    );
  }
}
