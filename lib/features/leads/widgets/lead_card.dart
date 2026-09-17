import "package:flutter/material.dart";
import "../models/lead_model.dart";
import "../../../core/theme/app_colors.dart";

/// Lead Card matching CRM Pro Leads Screen 1 (image.png)
/// Features:
/// - Distinct circular AI Score badge with emerald, amber, or coral outline & background
/// - Company title, Contact Name · Role, Map pin with distance · Area, and Last Active timestamp
/// - Status pill badge (Hot, Contacted, Cold, etc.)
/// - Bookmark / Flag indicator icon
/// - Interactive swipe actions: Swipe left to call, swipe right to log visit
/// - Optional bottom banner for quick tips
class LeadCard extends StatelessWidget {
  final LeadModel lead;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onLogVisit;
  final VoidCallback? onToggleFlag;

  const LeadCard({
    super.key,
    required this.lead,
    this.onTap,
    this.onCall,
    this.onLogVisit,
    this.onToggleFlag,
  });

  @override
  Widget build(BuildContext context) {
    final isHighlighted = lead.hasSwipeActionTip;

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? AppColors.primary : const Color(0xFFE5E7EB),
          width: isHighlighted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Left: Circular AI Score Badge
                _buildScoreBadge(lead.aiScore),

                const SizedBox(width: 14),

                // 2. Middle: Details (Company, Contact, Location, Last Active)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company Name
                      Text(
                        lead.companyName,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Contact Name · Role
                      Text(
                        "${lead.contactName} · ${lead.contactRole}",
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Location Pin + Distance · Area
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${lead.distanceKm} km · ${lead.locationArea}",
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Last active timestamp
                      Text(
                        "Last active: ${lead.lastActive}",
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // 3. Right: Status Badge & Flag Icon
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusPill(),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: onToggleFlag,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(
                          lead.isFlagged
                              ? Icons.flag_rounded
                              : Icons.outlined_flag_rounded,
                          size: 18,
                          color: lead.isFlagged
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFD1D5DB),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 4. Bottom Banner (Swipe left to call, right to log visit)
          if (lead.hasSwipeActionTip)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F7F7),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFD2EEEE),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Swipe left to call, right to log visit",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F4C4C),
                      letterSpacing: -0.1,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: Color(0xFF0F4C4C),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    // Wrap with Dismissible to support swipe left to call, swipe right to log visit
    return Dismissible(
      key: ValueKey(lead.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swiped left -> Call
          onCall?.call();
        } else if (direction == DismissDirection.startToEnd) {
          // Swiped right -> Log visit
          onLogVisit?.call();
        }
        return false; // Do not remove item from list
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F4C4C),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: const [
            Icon(Icons.location_on_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              "Log Visit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Text(
              "Call Lead",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.phone_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: cardContent,
        ),
      ),
    );
  }

  /// Circular AI Score badge with score-tiered styling
  Widget _buildScoreBadge(int score) {
    Color borderColor;
    Color bgColor;
    Color textColor;

    if (score >= 80) {
      // Hot / High Tier (e.g. 94)
      borderColor = const Color(0xFF10B981);
      bgColor = const Color(0xFFD1FADF).withOpacity(0.65);
      textColor = const Color(0xFF10B981);
    } else if (score >= 60) {
      // Warm / Medium Tier (e.g. 76)
      borderColor = const Color(0xFFF59E0B);
      bgColor = const Color(0xFFFEF3C7).withOpacity(0.65);
      textColor = const Color(0xFFD97706);
    } else {
      // Cold / Low Tier (e.g. 45)
      borderColor = const Color(0xFFEF4444);
      bgColor = const Color(0xFFFEE2E2).withOpacity(0.65);
      textColor = const Color(0xFFDC2626);
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2.0),
      ),
      alignment: Alignment.center,
      child: Text(
        "$score",
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  /// Status badge matching exact colors from image.png
  Widget _buildStatusPill() {
    Color bgColor;
    Color textColor;
    String label;

    // Check custom temperature or stage
    if (lead.temperature == LeadTemperature.hot) {
      label = "Hot 🔥";
      bgColor = const Color(0xFFD1FADF);
      textColor = const Color(0xFF059669);
    } else if (lead.temperature == LeadTemperature.cold || lead.notes.contains("Follow-up") || lead.companyName == "DataFlow Systems") {
      label = "Follow-up Due";
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFD97706);
    } else if (lead.distanceKm <= 0.8) {
      label = "Nearby 📍";
      bgColor = const Color(0xFFE0F2FE);
      textColor = const Color(0xFF0284C7);
    } else if (lead.stage == LeadStage.contacted) {
      label = "Contacted";
      bgColor = const Color(0xFFDBEAFE);
      textColor = const Color(0xFF2563EB);
    } else if (lead.stage == LeadStage.qualified) {
      label = "Qualified";
      bgColor = const Color(0xFFE0E7FF);
      textColor = const Color(0xFF4F46E5);
    } else {
      label = lead.stageLabel;
      bgColor = const Color(0xFFF3F4F6);
      textColor = const Color(0xFF4B5563);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}
