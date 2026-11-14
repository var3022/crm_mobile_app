You are working in my existing Flutter CRM mobile app. Complete the missing
screens, design states and local functionality from my exported Figma PDF.
Implement the work; do not stop after an audit or plan.

Project: C:\Users\Asus\Documents\ChatGPT\Yutomax\crm_mobile_app
Design reference: C:\Users\Asus\Downloads\crm mobile application.pdf
Gap checklist: C:\Users\Asus\Documents\ChatGPT\Yutomax\crm_mobile_app\DESIGN_GAP_AUDIT.md
Implementation notes: C:\Users\Asus\Documents\ChatGPT\Yutomax\crm_mobile_app\IMPLEMENTATION.md

Read the repository instructions, current source and both Markdown files before
editing. Preserve existing user changes. The current implementation has working
navigation, shared in-memory records, many screens, bundled Inter/map/photo
assets, a successful web build and a baseline of 74 passing tests. Extend this
implementation; do not replace it with a different application or another stack.
The Flutter app is under lib/. The React/Vite src/ directory is an older preview
and code viewer, not the target application.

1. Audit the complete PDF visually and build a screen/state matrix.
   Record PDF page and sub-screen, route/widget, current status, missing controls,
   required interactions and verification evidence. Render readable references
   and compare them with screenshots of the running Flutter app. A PDF page can
   contain several screens: page 11 includes multiple 2FA states and page 77
   includes photo selection/detail/delete, voice library/player/delete and empty
   media states. Pages 36 and 102–105 are design/navigation references, not extra
   product pages. Do not count a route, popup, generic form or static image as
   proof a complete design state or feature exists.

2. Implement the missing distinct screens and compositions first.
   Add authenticator enrollment/QR/manual key, verification and backup-code UI;
   voice-note library and player; recording deletion with acknowledgement; photo
   selection/bulk actions, metadata/OCR and deletion; empty media library; and
   separate route-planning versus active-route screens. Reproduce the PDF's
   bottom sheets, overlays and validation states. Reuse the app's tokens,
   components and bundled assets. Do not use whole-screen screenshots as UI.

3. Complete the incomplete existing screens using DESIGN_GAP_AUDIT.md.
   This includes recent-search history; the full filter sheet; all lead fields
   and duplicate View/Merge/Create actions; conversion welcome-deal/team/email
   options; note attachments/pinning; filtered activity; deal next actions/reason
   chips/Create & Schedule Visit; visit calendar/time slots and active-route
   controls; GPS/check-in resolution states; rich visit notes, checklist additions
   and signature options; checkout next steps/follow-up; task time/reminders/status
   and deal links; report/date-range/export sheets; profile photo; quiet hours;
   support/legal destinations; targets/team comparison and visit-history export.
   Preserve navigation, selected records, back/cancel behavior, validation and
   empty/loading/error/success states. Saved fields must be reflected when the
   record is reopened. Follow-up and next-action controls must create actual
   linked records/reminders where applicable.

4. Implement durable local functionality before depending on remote services.
   Add repositories and local persistence for accounts, deals, visits, tasks,
   notes, activity, preferences, media metadata and signatures. Seed demo data
   once. Use stable IDs and record relationships rather than company names as
   keys. Keep visit notes/media associated with the visit and account. Preserve
   the timer across navigation/restart, calculate actual duration, and derive
   counts, history, reports, targets and date comparisons from data. Implement
   duplicate merging without losing linked records, real local PDF/XLSX/CSV
   downloads and storage cleanup with confirmation. Never report successful
   persistence/export/sync unless it actually happened.

5. Connect platform capabilities where configuration permits.
   Implement camera/gallery capture, audio recording/playback/speed, file sharing,
   system phone/email/WhatsApp/directions handoffs, permission handling, location
   checks and notification/reminder scheduling. Ensure browser preview gracefully
   handles capabilities that are only available on supported mobile devices.
   Generate Android scaffolding if absent and configure required permissions.
   Keep native and web behavior explicit; do not let unavailable services crash
   the preview. Keep PDF reference media separate from user-captured media.

6. Keep external-service boundaries honest.
   First discover any existing backend/authentication/API configuration. Do not
   invent credentials, hardcode tokens, fabricate authentication/GPS verification,
   transcription, AI output, route optimization, notification delivery or sync.
   For authentication/SSO/2FA, map/routing APIs, transcription/OCR/AI, email,
   support endpoints and server synchronization, provide typed adapters and
   documented environment configuration. Implement credential-independent work
   first. Ask one concise bundled question only if a provider choice or secret is
   actually required, and continue unrelated implementation while waiting. Do
   not create a paid account, purchase services, send real emails/messages or
   publish/deploy anything without authorization. Clearly separate demo fixtures
   from production behavior and list integration blockers rather than claiming
   those features are finished.

7. Match the PDF visually and verify behavior.
   Reuse the 390px reference width while supporting smaller widths, scrolling,
   safe areas, keyboard visibility and accessibility. Match typography, color,
   spacing, field grouping, chips, icons, cards, circular back buttons, navigation
   and modal placement. Replace shared generic form arrangements when they
   cannot reproduce the reference. Keep Inter local and avoid runtime font
   downloads for offline paths. Compare meaningful screenshots for each distinct
   screen/state, including composite-page sub-screens. Fix clipped text,
   overflows and missing assets. Route-mount tests alone do not prove fidelity.

8. Validate and report precisely.
   Run dart format, flutter analyze, flutter test and a Flutter web build. Preserve
   the existing 74-test baseline, add meaningful tests for persistence, relation
   integrity, duplicate merge, timers, validation, conversion, reminders, filters,
   export files and media/permission states. Add regression tests for corrected
   behavior. Verify Android on a supported device/emulator if available; report
   any native validation you cannot execute. Fix errors and new warnings; separate
   pre-existing lint/deprecation debt from new failures. Update the page/state
   matrix and IMPLEMENTATION.md with evidence and remaining external blockers.

Start by inspecting the PDF and current implementation, then proceed with the
missing UI/local features. Preserve the screen browser command:

flutter run -d chrome --dart-define=APP_ROUTE=/screen-index

At the end, give me the actual completed-screen/state list, tests/build results,
local run commands and an honest list of remaining provider-dependent work.
Do not describe the entire recreation as complete while preview-only actions,
unimplemented composite states or unverified design differences remain.
