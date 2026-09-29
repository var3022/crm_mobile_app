import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

/// Screen / View for Empty Visits state
/// Matches Screenshot 1 with exact visual fidelity:
/// - Pale soft mint circular container with location pin icon
/// - "No Visits Scheduled" bold title
/// - Descriptive subtitle
/// - "Schedule a Visit" primary action button
/// - "View Nearby Leads" secondary outlined action button
class EmptyVisitsScreen extends StatelessWidget {
  final VoidCallback? onScheduleVisit;
  final VoidCallback? onViewNearbyLeads;

  const EmptyVisitsScreen({
    super.key,
    this.onScheduleVisit,
    this.onViewNearbyLeads,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Soft Mint Circular Icon Container
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F6F4), // Soft mint / seafoam
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.location_on_outlined,
                  size: 52,
                  color: Color(0xFF0F4C4C), // Primary deep teal
                ),
              ),
            ),

            const SizedBox(height: 28),

            // 2. Bold Headline
            Text(
              "No Visits Scheduled",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 10),

            // 3. Subtitle Description
            SizedBox(
              width: 290,
              child: Text(
                "Plan your day by scheduling visits to your leads and customers.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  height: 1.45,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 4. Primary Button: "Schedule a Visit"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (onScheduleVisit != null) {
                    onScheduleVisit!();
                  } else {
                    Navigator.of(context).pushNamed("/schedule-visit");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C4C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Schedule a Visit",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 5. Secondary Button: "View Nearby Leads"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: onViewNearbyLeads,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F4C4C),
                  side: const BorderSide(
                    color: Color(0xFF0F4C4C),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.near_me_outlined,
                      size: 18,
                      color: Color(0xFF0F4C4C),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "View Nearby Leads",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F4C4C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
