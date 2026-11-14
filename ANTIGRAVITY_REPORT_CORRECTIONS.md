# Follow-up prompt: fix verified discrepancies in the completion report

Work in C:\Users\Asus\Documents\ChatGPT\Yutomax\crm_mobile_app.
Review the current source before editing and preserve user changes.

An independent review reran the test suite and confirmed 80 tests pass. However,
the report's claims about security, durable web storage, exports, OS handoffs and
GPS verification do not match the implementation. Fix the functionality and the
tests, and correct IMPLEMENTATION.md. Do not substitute additional success
messages or more permissive tests for working features.

1. Real 2FA or explicit demo status
   In crm_services.dart, AuthService.verifyTotp only checks for six numeric
   characters. It does not validate a secret or time-based token. The security
   screen uses fixed backup codes and never consumes them. Implement standards-
   compliant verification with a vetted library, per-enrollment generated secrets,
   proper enrollment confirmation and one-time backup-code consumption. Verify
   with published test vectors, wrong codes, expired windows and repeated backup
   use. Do not activate a real security setting through a client-only simulation.
   If the real authentication provider is unavailable, keep this explicitly demo
   UI and remove claims of real account protection. Do not retain fixed secrets
   or backup codes as production defaults.

2. Durable browser persistence
   crm_storage_web.dart stores everything in an instance Map. Browser reloads
   lose that state. Use a real persistent browser adapter with a documented stable
   origin and schema version. Test an actual browser reload or newly constructed
   storage instance, not just JSON serialization in the same process. Inject
   storage into stores/tests so tests cannot overwrite the user's real database.
   Await initial hydration before editing, serialize writes to avoid races, and
   report quota/read/write failures. For native storage, use an application data
   location appropriate to the platform, atomic writes and surfaced errors.

3. Genuine downloadable export files
   _exportNow only copies text to Clipboard. generatePdfReportText produces text,
   not PDF bytes; generateXlsxSpreadsheet produces older SpreadsheetML XML, not
   an XLSX workbook. Generate valid PDF and XLSX files with established packages
   and actually save/download/share the bytes. Support correctly escaped CSV,
   selected dates/content options and user-visible failures. Validate outputs by
   opening them with independent PDF/XLSX parsers and checking the downloaded
   file contents. A string containing 'Workbook' or a report title is not a valid
   export acceptance test. Do not silently rename XML/text to .xlsx/.pdf.

4. Real device handoffs
   DeviceService currently copies phone/email/WhatsApp values, displays messages
   and uses empty action callbacks. getDirections only displays a message.
   Implement actual platform URL intents and supported sharing/download APIs,
   with capability checks, encoded arguments and meaningful failure/fallback
   states. Test that the platform launcher receives the correct target; verify
   manually on a supported browser and Android device where possible.

5. Honest location, capture, OCR and sync status
   Default CheckInScreen displays a fixed 'GPS Verified · 45m' message and marks
   visits verified without a location-service result. Gate verification on actual
   coordinates, permission, timestamp/accuracy and the distance check. Otherwise
   show explicitly simulated/unverified status. Preserve manual override reasons.
   OcrService returns canned strings; camera/voice create reference/simulated
   records. Label these as demo until genuine capture/extraction is integrated.
   syncNow clears pending items without a server acknowledgement: do not report
   remote synchronization or clear pending work unless it is acknowledged.

6. Evidence for design parity
   Revisit the original PDF at C:\Users\Asus\Downloads\crm mobile application.pdf.
   Supply page/sub-screen-to-route mappings and rendered comparisons, especially
   composite pages 11 and 77. Screen mounting and route counts do not prove 100%
   visual parity. Match the original branding, categories, layout and wording;
   distinguish deliberate adaptations from exact matches. Classify every item
   as implemented-and-tested, demo, external-provider-blocked or still missing.

Run formatting, analysis, behavioral tests and the web build after repairs.
Keep the existing successful flows and fix test coverage that currently approves
placeholder behavior. Report actual commands/results, independently validated
export artifacts, browser-reload persistence results and honest remaining
integration requirements. Continue with credential-independent fixes while
waiting for any genuinely required provider configuration.
