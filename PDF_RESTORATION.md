# PDF content restoration

Implemented against the content audit of the supplied 105-page CRM design. Existing saved records are preserved. Reference numbers, dates and team rankings are not substituted for actual user data.

## Restored screens and behavior

| PDF pages | Changes |
| --- | --- |
| 31 | Lead filters include Date Added presets/custom range and Assigned To. Both affect the count and returned records. Hot/Warm/Cold map to the stored High/Medium/Low priorities. |
| 33, 37 | Lead forms have Contact Person, Company Details, Location Details, Lead Logistics and Attachments sections. Name and industry/company-size fields are paired. Walk-in is available. GPS requests real permission/location; denied/unavailable requests show an error. Visiting cards can be attached with the system file picker. Save & Schedule Visit persists before opening scheduling. Delete requires confirmation. |
| 44 | Notes include original categories, title/body, real file attachments, pinning and a saved team-notification request. Attachment bytes and metadata persist; account notes expose attachment downloads. Pinned notes sort first. |
| 46 | Two compact pipeline columns fit at mobile width. Qualified and Proposal appear first, with counts and stage totals. Cards wrap without breaking currency values across lines. |
| 48, 50 | Deal values use INR. Stage chips and probability slider replace generic controls. Update includes quick reason chips; create includes Create & Schedule Visit. |
| 71, 73 | Task deadlines include date and time, with readable localized display. Reminder preferences persist with the deadline. Edit supports linked deals, status and confirmed deletion. |
| 78 | Reports have the original four metric groups, target denominators/progress indicators, seven-day last-week activity, pipeline stage counts and the performance banner area. Metrics use the selected period and completed visits. Comparison displays the actual preceding-period visit count. |
| 79 | Date-range bottom sheet includes presets, FROM/TO selection, calendar, comparison switch and Apply Filter. |
| 80 | Export sheet includes PDF/Excel/CSV, Charts/Raw Data/Summary/Team Breakdown and optional email copy. Selections control actual generated sections. PDF includes chart output; spreadsheet/CSV include chart data. Team rows aggregate available deal-owner data. Email opens a composer after download and explicitly requires attaching the downloaded file. |
| 81 | Profile uses the compact rounded avatar, organization/territory line and original menu order, including storage/version labels. Performance values are derived consistently rather than fabricated fallback revenue and conversion. |
| 83 | Settings has rounded groups for Account, Notifications, Location & Tracking, Offline & Data and AI Settings. Extra 2FA/quiet-hours destinations remain accessible through the overflow menu. |
| 88 | Targets uses a selectable month, INR targets, the original five cards, percentage-driven ring and bottom navigation. Target benchmarks are 50 visits, INR 10L revenue, 20 new leads and INR 1.5L average deal size. |
| 89 | Visit History filters records by selected month and shows unique clients. Export History creates an actual CSV for that month. |
| 90 | Separate Leads Data, Customer Profiles, Visit Logs, Photos & Media and Voice Notes rows. Sizes are calculated from serialized local records; small amounts display as KB. Download All for Offline saves the complete local JSON snapshot including note attachments. Bundled reference media stays in the application assets. |
| Shared patterns | Circular back controls, larger main-page titles, rounded chips/group panels and consistent form sections. Existing top safe-area spacing is retained. |

## Integration boundaries

- The design's sample values are not live metrics. Team ranking/average require team data; unavailable states are shown instead of invented ranks.
- OCR, AI probability suggestions, automatic team notifications and scheduled OS notification delivery are not supplied by this UI restoration. Visiting-card attachments support manual entry. Reminder and notification requests are saved, but are not claimed to have been delivered.
- Email opens an external composer; the app does not claim server delivery or automatic attachment through mailto.
- The offline backup covers local records and attached file bytes. It does not fetch unavailable server records. The existing remote sync gateway is still unconfigured.
- Device GPS now uses `geolocator`, with permission/error handling. Native Android build and sensor verification remain pending until the Android SDK is configured.
- These changes restore audited content and behavior. They are not a certification of exact pixels for every composite state in all 105 PDF pages.

## Verification

- `flutter test --no-pub`: 112 passing tests (including 10 restoration regression tests).
- `flutter test tool/capture_design_review.dart --no-pub`: capture check passes for 23 routes and 2 report sheets at 390 x 844.
- Regression coverage includes month isolation, year rollover, owner/date filters, time/reminder persistence, note attachment reload, pin ordering and PDF/CSV/XLSX content selection.
- Screenshot captures are written to `../tmp/pdfs/app-review` when running the capture command from the project root.
- Web debug compilation is checked separately; this does not establish native Android behavior.

Dependencies added: `file_selector` for file attachment selection, `geolocator` for real GPS acquisition and direct `web` declaration for existing web adapters.
