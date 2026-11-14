import "dart:math" as math;
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_spacing.dart";
import "../../workspace/crm_store.dart";

/// Dashboard and Notification Screen 1: Screen-Dashboard
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
/// Features:
/// - Hidden scrollbars for smooth, clean mobile scrolling
/// - Status bar, user greeting, sync indicator & notification bell with badge count
/// - AI Daily Brief card with action link
/// - Horizontal metrics carousel with hidden scrollbar
/// - Circular progress Monthly Target tracker
/// - Interactive Today's Schedule cards with status indicators
/// - Floating Action Button for quick check-in / new lead
/// - Bottom Navigation Bar with active 'Home' indicator
class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onViewAllMapTap;
  final VoidCallback? onFabTap;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onViewBriefTap;
  final ValueChanged<String>? onScheduleItemTap;

  const DashboardScreen({
    super.key,
    this.onNotificationTap,
    this.onViewAllMapTap,
    this.onFabTap,
    this.onNavTap,
    this.onViewBriefTap,
    this.onScheduleItemTap,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Static Top Bar + Main Scrollable Content Area
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // 1. Static Top Bar (pinned, does not scroll): Avatar, Greeting, Synced Chip, Notification Bell
                _buildTopHeader(),

                const SizedBox(height: 10),

                // Main content area with scrollbar strictly hidden
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. AI Daily Brief Card
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                            ),
                            child: _buildAiDailyBriefCard(),
                          ),

                          const SizedBox(height: 20),

                          // 3. Horizontal Metric Cards Carousel (hidden scrollbar)
                          _buildMetricsCarousel(),

                          const SizedBox(height: 20),

                          // 4. Monthly Target Progress Card
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                            ),
                            child: _buildMonthlyTargetCard(),
                          ),

                          const SizedBox(height: 24),

                          // 5. Section Header: "Today's Schedule" + "View All Map"
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Today's Schedule",
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: widget.onViewAllMapTap,
                                  child: Text(
                                    "View All Map",
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F4C4C),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // 6. Schedule List Cards
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenHorizontal,
                            ),
                            child: Column(
                              children: [
                                _buildScheduleCard(
                                  time: "09:30 AM",
                                  status: "completed",
                                  company: "Acme Corp",
                                  contact: "John Doe (CTO)",
                                  location: "Nariman Point, South Mumbai",
                                  isCompleted: true,
                                ),
                                const SizedBox(height: 12),
                                _buildScheduleCard(
                                  time: "11:45 AM",
                                  status: "completed",
                                  company: "TechVista Ltd",
                                  contact: "Priya Sharma (HR)",
                                  location: "Lower Parel, Mumbai",
                                  isCompleted: true,
                                ),
                                const SizedBox(height: 12),
                                _buildScheduleCard(
                                  time: "02:30 PM",
                                  status: "upcoming",
                                  company: "DataFlow Systems",
                                  contact: "Karan Malhotra (MD)",
                                  location: "Andheri East, Mumbai",
                                  isCompleted: false,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Floating Action Button (placed above bottom navigation) - square with curved edges
            Positioned(
              right: 20,
              bottom: 84,
              child: GestureDetector(
                onTap: widget.onFabTap,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F4C4C),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F4C4C).withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),

            // Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavigationBar(),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Top Header Row
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Row(
        children: [
          // User Avatar Initial ("AM")
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "AM",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F4C4C),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Greeting & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Good morning,...",
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Thursday, Aug 9",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // "• Synced" status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "Synced",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Notification Bell Button with "3" badge
          GestureDetector(
            onTap: widget.onNotificationTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF1F2937),
                      size: 22,
                    ),
                  ),
                ),

                // Red notification badge
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "3",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. AI Daily Brief Card
  Widget _buildAiDailyBriefCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F4C4C),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C4C).withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Robot/Brain Icon + "AI DAILY BRIEF"
          Row(
            children: [
              const Text("🤖", style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                "AI DAILY BRIEF",
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF99F6E4),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Brief Body
          Text(
            "You have 6 visits planned today. 2 are high-priority. Start with Acme Corp they viewed your proposal yesterday.",
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.92),
              height: 1.45,
              letterSpacing: -0.1,
            ),
          ),

          const SizedBox(height: 14),

          // "View Full Brief →" link
          GestureDetector(
            onTap: widget.onViewBriefTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "View Full Brief",
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  "→",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Horizontally Scrollable Metric Cards Carousel with scrollbars hidden
  Widget _buildMetricsCarousel() {
    final store = CrmStore.instance;
    final totalVisits = store.visits.length;
    final completedVisits = store.visits
        .where((v) => v.status == 'Completed')
        .length;
    final inProgressVisits = store.visits
        .where((v) => v.status == 'In Progress')
        .length;
    final totalCheckins = completedVisits + inProgressVisits;
    final activeLeadsValue = store.leads.fold<double>(
      0,
      (s, l) => s + l.accountValue,
    );
    final revenueLakhs = (activeLeadsValue / 100000.0).toStringAsFixed(1);

    final metrics = [
      _MetricItem(
        title: "Today's Visits",
        value: "$completedVisits/$totalVisits",
        subtitle: "Goal: $totalVisits visits",
      ),
      _MetricItem(
        title: "Check-ins",
        value: "$totalCheckins",
        subtitle: "Active/Done",
      ),
      _MetricItem(
        title: "Distance",
        value: "18 km",
        subtitle: "Estimated (Sample)",
      ),
      _MetricItem(
        title: "Revenue",
        value: "₹${revenueLakhs}L",
        subtitle: "Active leads",
      ),
    ];

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Row(
          children: metrics.map((item) {
            return Container(
              width: 124,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.value,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F4C4C),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9CA3AF),
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 4. Monthly Target Card with circular progress
  Widget _buildMonthlyTargetCard() {
    final store = CrmStore.instance;
    final wonDeals = store.deals.where((d) => d.stage == 'Won').toList();
    final totalWon = wonDeals.fold<double>(0, (sum, d) => sum + d.value);
    const targetAmount = 1000000.0;
    final percentage = (totalWon / targetAmount).clamp(0.0, 1.0);
    final percentInt = (percentage * 100).round();
    final achievedLakhs = (totalWon / 100000.0).toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Progress Indicator with center percentage
          SizedBox(
            width: 68,
            height: 68,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(68, 68),
                  painter: _CircularProgressPainter(
                    percentage: percentage,
                    trackColor: const Color(0xFFF1F5F9),
                    progressColor: const Color(0xFF0F4C4C),
                    strokeWidth: 6.5,
                  ),
                ),
                Text(
                  "$percentInt%",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F4C4C),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          // Label, Target Numbers and Days remaining
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "MONTHLY TARGET",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B7280),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${achievedLakhs}L / ₹10.0L",
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "22 days remaining",
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD97706),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Individual Schedule Item Card
  Widget _buildScheduleCard({
    required String time,
    required String status,
    required String company,
    required String contact,
    required String location,
    required bool isCompleted,
  }) {
    return GestureDetector(
      onTap: () {
        if (widget.onScheduleItemTap != null) {
          widget.onScheduleItemTap!(company);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Time and Status Dot
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F4C4C),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : const Color(0xFF0F4C4C),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Subtle vertical line or spacing
            Container(
              height: 48,
              width: 1,
              color: const Color(0xFFF3F4F6),
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),

            // Right Column: Company, Contact, Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9CA3AF),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 6. Bottom Navigation Bar with pill highlight for active tab
  Widget _buildBottomNavigationBar() {
    final navItems = [
      _BottomNavItemData(
        label: "Home",
        icon: Icons.home_rounded,
        outlinedIcon: Icons.home_outlined,
      ),
      _BottomNavItemData(
        label: "Leads",
        icon: Icons.folder_rounded,
        outlinedIcon: Icons.folder_outlined,
      ),
      _BottomNavItemData(
        label: "Visits",
        icon: Icons.share_location_rounded,
        outlinedIcon: Icons.share_location_outlined,
      ),
      _BottomNavItemData(
        label: "Tasks",
        icon: Icons.format_list_bulleted_rounded,
        outlinedIcon: Icons.format_list_bulleted_outlined,
      ),
      _BottomNavItemData(
        label: "Profile",
        icon: Icons.manage_accounts_rounded,
        outlinedIcon: Icons.manage_accounts_outlined,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 20, left: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isActive = _currentNavIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentNavIndex = index;
              });
              if (widget.onNavTap != null) {
                widget.onNavTap!(index);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: isActive
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4F2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: const Color(0xFF0F4C4C),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F4C4C),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.outlinedIcon,
                          size: 22,
                          color: const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        }),
      ),
    );
  }
}

/// Circular progress painter for Monthly Target gauge
class _CircularProgressPainter extends CustomPainter {
  final double percentage;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.percentage,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track Paint
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc Paint
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * percentage;
    const startAngle = -math.pi / 2; // starts at 12 o'clock

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _MetricItem {
  final String title;
  final String value;
  final String subtitle;

  _MetricItem({
    required this.title,
    required this.value,
    required this.subtitle,
  });
}

class _BottomNavItemData {
  final String label;
  final IconData icon;
  final IconData outlinedIcon;

  _BottomNavItemData({
    required this.label,
    required this.icon,
    required this.outlinedIcon,
  });
}
