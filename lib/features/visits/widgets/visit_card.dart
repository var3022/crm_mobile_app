import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../models/visit_model.dart";

/// Visit Card with integrated Timeline indicator on the left
/// Matches the exact visual fidelity of CRM Pro Visits Screen (Screenshot 2).
class VisitCard extends StatelessWidget {
  final VisitModel visit;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onTap;

  const VisitCard({
    super.key,
    required this.visit,
    this.isFirst = false,
    this.isLast = false,
    this.onPrimaryAction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isInProgress = visit.status == VisitStatus.inProgress;
    final isCompleted = visit.status == VisitStatus.completed;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Timeline node & connector column on the left
          SizedBox(
            width: 28,
            child: Column(
              children: [
                // Top vertical line spacer
                Container(
                  width: 2,
                  height: 14,
                  color: isFirst
                      ? Colors.transparent
                      : (isCompleted
                          ? const Color(0xFF0F4C4C)
                          : const Color(0xFFE5E7EB)),
                ),

                // Status Indicator Dot / Ring
                _buildTimelineNode(isInProgress, isCompleted),

                // Bottom connecting vertical line
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : (isCompleted
                            ? const Color(0xFF0F4C4C)
                            : const Color(0xFFE5E7EB)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 2. Main Visit Card Container
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isInProgress
                          ? const Color(0xFF0F4C4C)
                          : const Color(0xFFE5E7EB),
                      width: isInProgress ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isInProgress ? 0.05 : 0.02,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header: Status + Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _buildStatusText(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _getStatusColor(),
                              letterSpacing: 0.3,
                            ),
                          ),
                          _buildMeetingBadge(),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Company Name
                      Text(
                        visit.companyName,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Contact Name · Role
                      Text(
                        "${visit.contactName} · ${visit.contactRole}",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4B5563),
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Location Area
                      Text(
                        visit.locationAddress,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Action Button
                      _buildActionButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(bool isInProgress, bool isCompleted) {
    if (isCompleted) {
      return Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(
          color: Color(0xFFCCFBF1), // Soft mint outer circle
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981), // Solid green dot
            shape: BoxShape.circle,
          ),
        ),
      );
    } else if (isInProgress) {
      return Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(
          color: Color(0xFFCCFBF1), // Soft mint outer circle
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 9,
          height: 9,
          decoration: const BoxDecoration(
            color: Color(0xFF0F4C4C), // Deep teal dot
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      return Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(
          color: Color(0xFFF3F4F6), // Soft grey outer circle
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF9CA3AF), // Solid grey dot
            shape: BoxShape.circle,
          ),
        ),
      );
    }
  }

  String _buildStatusText() {
    switch (visit.status) {
      case VisitStatus.completed:
        return "${visit.time} · COMPLETED";
      case VisitStatus.inProgress:
        return "${visit.time} · IN PROGRESS";
      case VisitStatus.upcoming:
        return "${visit.time} · UPCOMING";
      case VisitStatus.cancelled:
        return "${visit.time} · CANCELLED";
    }
  }

  Color _getStatusColor() {
    switch (visit.status) {
      case VisitStatus.completed:
        return const Color(0xFF0D9488); // Teal-green
      case VisitStatus.inProgress:
        return const Color(0xFF0F4C4C); // Deep Teal
      case VisitStatus.upcoming:
        return const Color(0xFF4B5563); // Neutral grey-slate
      case VisitStatus.cancelled:
        return const Color(0xFFEF4444); // Red
    }
  }

  Widget _buildMeetingBadge() {
    final bool isDemo = visit.meetingType.toLowerCase().contains("demo");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDemo ? const Color(0xFFF3F4F6) : const Color(0xFFCCFBF1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        visit.meetingType,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDemo ? const Color(0xFF4B5563) : const Color(0xFF0F4C4C),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (visit.status == VisitStatus.inProgress) {
      return SizedBox(
        width: double.infinity,
        height: 42,
        child: ElevatedButton(
          onPressed: onPrimaryAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F4C4C),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            "Start Visit",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    final String label =
        visit.status == VisitStatus.completed ? "View Summary" : "View Details";

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: onPrimaryAction,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF9FAFB),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}
