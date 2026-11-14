# Remaining design and functionality gaps

Source-level audit against the user's 105-page `crm mobile application.pdf`,
November 14, 2026. This is a confirmed implementation-gap checklist, not a claim
that every pixel of every original screen has been visually verified.

The PDF page count is not the screen count. Pages 11, 12, 19 and especially 77
contain multiple states/screens. Pages 36 and 102–105 contain navigation/design
documentation and should guide implementation rather than become product pages.

## 1. Missing distinct screens and states

| PDF reference | Confirmed gap |
| --- | --- |
| 11 | Actual authenticator enrollment screen with QR/manual key, backup-code saving, verification-code screen and backup-code alternative. `/security` is currently only an overview. |
| 77 | Voice Notes library with category filters, durations, linked visit/account, dates and transcription states. |
| 77 | Recording Player with playable audio, progress/seek, speed, transcript and transcript sharing. |
| 77 | Recording deletion confirmation with the acknowledgement checkbox. |
| 77 | Gallery selection mode, selected count, bulk share/download/delete. |
| 77 | Full Photo Preview metadata/OCR state and photo deletion confirmation. Current photo detail only displays/zooms a reference image. |
| 77 | Empty Media Library / No Captures Yet screen and its navigation actions. |
| 59–60 | Separate Plan Route and Today's Route experiences. Both routes currently resolve to the same simplified NearbyScreen in route mode. |

## 2. Existing screens with missing controls or simplified layouts

| PDF reference | Work still needed |
| --- | --- |
| 12, 19 | Match account/settings and permission-summary layouts, and the permission-skip overlay composition. Existing shared settings/permission screens do not reproduce all these states. |
| 29–30 | Dedicated search presentation with recent searches, selectable/clearable history, clear filters and browse-all empty-state actions. Current search is an inline field. |
| 31 | Complete filter sheet: date-added presets/custom range, assigned-to, deal-value range, and full lead-stage/source/priority controls. Current filter screen only handles stage, priority, source and score. |
| 33, 37 | Lead form sections, paired fields, industry, company size and location controls. Current generic forms omit some fields and use a different arrangement. |
| 34 | Duplicate detection sheet with View Existing and Merge Records. Current dialog offers cancellation or Create Anyway only. |
| 35, 38–39, 43 | Complete contact/customer action layouts; actual call, email, WhatsApp and directions handoffs. Call currently opens a log form; email/WhatsApp copy contact information. Call follow-up date/next-action inputs are not turned into actual reminders/actions. |
| 39 | Assign-to-team, welcome-deal creation and welcome-email toggle/actions. Initial Deal Value currently does not create a deal. Retain and migrate linked history when converting. |
| 44 | Note file attachments, pin-to-top, notify-team and their saved state. |
| 45 | Activity-type filters, actual event timestamps/counts and distinct visit/call/email/note/deal events. Current timeline derives a small view from notes/visits/deals. |
| 48–50 | Create & Schedule Visit, deal-stage stepper, probability slider/validation, quick-reason chips, next action, owner/contact/competitor/decision-maker model bindings and complete activity/notes actions. Several displayed details are still sample values. |
| 51–53 | Match result and deletion overlay layouts. Deal-loss context is reduced to a plain text field rather than the complete reference composition. |
| 54–60 | Functional visit map view, current-schedule reschedule card, inline calendar/time slots, Add to Active Route, client-notification action, editable stops, add/reorder stops, avoid-tolls/highways controls, optimized-route comparison, distance/ETA totals and navigation. |
| 61–63 | Verifying-location state, successful in-radius state, last-known-location/manual-address choices, and out-of-radius directions/override sheet. Current routes primarily share a manual unverified check-in form. |
| 64–68 | Visit-specific notes/media records, rich note controls/voice memo, actual photo thumbnails/counts, Add Custom Checklist Item, signature pen options and editable signer details, durable signature file, next steps/follow-up date and summary-generation action. Timer resets on navigation; summary duration is currently hardcoded to 45 minutes. |
| 71–73 | Task due time, reminder switch/scheduling, task status editing, linking a deal as well as a lead, and accurate saved assignment/activity fields. Current task form mainly stores a due date and the details screen includes sample history. |
| 75–77 | Camera capture/flash/switching, card scan/OCR, actual audio recording/playback/transcription, media metadata, persistent media storage and deletion. Current camera uses a reference image; voice uses a reference waveform and a text-note fallback. |
| 78–80 | Date presets and comparison toggle, data filtering/aggregation, PDF/XLSX/CSV export selection, include-content options and email-copy action. Current metrics are samples, period selection does not recalculate them and export only copies text. |
| 81–85 | Profile photo editing, complete profile persistence, real password update, quiet-hours start/end selectors, urgent-notification option and actual notification preferences/delivery. |
| 86 | Chat/call/email support handoffs, Terms and Privacy destinations and their configuration. Current help screen mainly provides FAQs and administrator guidance. |
| 87–89 | Data-derived distance/time/highlights, average-deal-size target, team comparison/ranking, history month filters, real visit durations/outcomes and Export History. Current screens are simplified and use mixed sample/session metrics. |
| 90–100 | Actual storage usage/cache breakdown/cleanup, sync status/progress, connectivity-triggered offline state, reconnect/retry behavior, session expiry and authorization/subscription/maintenance handling. Error-state routes exist but are mostly manually opened previews. |
| 36, 102–105 | Apply exact dimensions, typography, spacing, bottom navigation, circular back buttons, modals, chips, tags and empty-state geometry consistently. Shared generic forms and dialogs still need visual comparison. |

## 3. Cross-cutting functionality

- `CrmStore` is in-memory. Restarting restores fixtures; records, media, signature,
  task state and preferences need durable local storage.
- Records are often linked by company-name strings. Introduce stable identifiers
  so editing a company name does not orphan notes, visits, deals or activity.
- Authentication, SSO, biometrics, password recovery/update and 2FA are not
  connected to an authentication provider. No real credential verification exists.
- GPS/geofencing, live maps/directions, camera/microphone permissions, OCR,
  recording, notifications, email delivery and server synchronization need real
  platform/service adapters.
- AI briefs, scores, suggestions, route optimization, transcription and summary
  generation need an actual implementation or an explicitly labeled demo mode.
- Generate/validate Android platform support. The original repository did not
  contain native platform projects; a successful web build does not validate
  mobile permissions or native plugins. iOS builds require a suitable Apple host.
- Keep genuine data and honest integration statuses. A popup or static reference
  image must not be counted as a working camera, sync, export, map or auth feature.

## Verification baseline

The last executed checks passed: 74 Flutter tests, a debug web build, and zero
Dart compiler errors. Lint/deprecation warnings remain. The screen tests check
mounting/layout errors, not exact PDF appearance or complete feature behavior.

Use this list as a backlog and verify the current source before each change.
Additional pixel-level differences may be found during rendered comparison.
