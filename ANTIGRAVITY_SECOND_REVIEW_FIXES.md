# Follow-up: remaining issues in the corrected report

Work in C:\Users\Asus\Documents\ChatGPT\Yutomax\crm_mobile_app.
Preserve existing changes. The current suite independently passes 82 tests.
Keep the genuine improvements (TOTP implementation, random secrets/codes,
localStorage, binary export generation and simulation labels).

Fix these remaining source-confirmed issues, rather than reporting all
discrepancies resolved:

1. Browser exports are not implemented. CrmStorage.saveExportFile only writes
   when !kIsWeb and returns null for the browser. Implement actual byte downloads
   with correct filenames/MIME types and revocation/cleanup. In _exportNow, do
   not pop the sheet and then rely on its disposed BuildContext. Preserve an
   appropriate mounted context and handle save success, cancellation and failure.
   Verify PDF/XLSX/CSV downloads in the actual browser, not only generator bytes.

2. DeviceService.launchUri only implements a Windows cmd/start branch outside
   injected test launchers. Implement production browser and Android/iOS launch
   adapters, preferably using a supported platform plugin. Do not count URI
   construction or customLauncher=true mocks as successful platform launch
   verification. Check unsupported schemes and denied popup/intent behavior.
   Keep clipboard fallback honest and separate from real sharing.

3. AuthService.verifyTotpCode without a secret still accepts any six-digit
   numeric input, despite its comment claiming rejection. Remove this permissive
   fallback and reject missing/invalid secrets. Add negative tests for that exact
   public helper. The security screen currently regenerates all enrollment
   state on every mount while persisting an enabled flag. Either persist the
   intended local-demo lifecycle securely and coherently or reset the enabled
   flag with clear demo semantics. Do not imply durable account protection from
   a widget-local verification state.

4. Native writes are not atomic on Windows: target.delete() occurs before tmp
   rename. A crash or rename failure can remove the last valid database. Use
   crash-safe replacement/recovery and test failure between write/replacement.
   Recover the serialized write queue after an individual failed write; the
   current .then chain prevents subsequent writes once rejected. Surface storage
   failures currently swallowed by CrmStore._saveToStorage. Use durable app data
   directories on Android/iOS instead of systemTemp. Gate edits on hydration or
   otherwise prevent saved data from overwriting early user edits.

5. Export validation is incomplete. Parse generated PDFs with an independent
   PDF reader and XLSX with a workbook reader, rather than checking headers,
   keywords or ZIP membership only. Render the PDF: the generator emits UTF-8
   rupee/non-ASCII characters using unembedded Helvetica, so correct Unicode
   rendering is not established. Add proper fonts/encoding, multipage pagination
   and complete record coverage (visits.take(15) currently truncates data).
   Apply selected reporting dates/options and actual metrics; the export UI
   currently passes Current Month and defaults rather than computed summary
   values. Verify content, dates, Unicode, many records and files users download.

6. Correct the evidence and design mapping. The actual 82-test suite consists
   of 69 screen smoke tests plus 13 workflow/logic tests, not 74 plus 13. The
   persistence test uses MemoryStorageAdapter across two stores; add a real
   browser localStorage reload test and native filesystem test before claiming
   those adapters verified. Provide a fixed development web port so separate
   launches use the same storage origin. Correct nonexistent route names such
   as /welcome, /walkthrough, /reset-link, /search-leads and /filtered-leads in
   the report, or implement the intended routes. Check PDF page assignments:
   pages 1–4 are splash/sign-in/sign-up/email verification, not walkthrough.
   Show rendered comparisons before claiming Figma fidelity. Mark remaining
   simulations/provider blockers and preserve their disclaimers.

Execute the implementation and tests, not just a documentation rewrite. Run
formatting, analysis, Flutter tests and web build. Report observed browser/native
results separately from mocked unit tests, and accurately list remaining work.
