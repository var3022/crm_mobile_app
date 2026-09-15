import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_spacing.dart";

/// Notification Item Data Model
class NotificationItem {
  final String id;
  final String title;
  final String time;
  final String category; // 'leads', 'visits', 'proposals', 'tasks', 'deals'
  final bool isUnread;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String? actionText;
  final VoidCallback? onAction;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.time,
    required this.category,
    required this.isUnread,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.actionText,
    this.onAction,
  });

  NotificationItem copyWith({bool? isUnread}) {
    return NotificationItem(
      id: id,
      title: title,
      time: time,
      category: category,
      isUnread: isUnread ?? this.isUnread,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      actionText: actionText,
      onAction: onAction,
    );
  }
}

/// Dashboard & Notification Screen 2 - Notifications (`screen-notification`)
/// Follows CRM Pro Flutter/Dart design system:
/// - Pinned static top header with count badge & "Mark All Read"
/// - Filter chips: All, Unread 5, Leads, Visits
/// - Scrollbars strictly hidden (invisible per specification)
/// - Bottom navigation bar in floating rounded card style
class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onLeadsTap;
  final VoidCallback? onVisitsTap;
  final VoidCallback? onTasksTap;
  final VoidCallback? onProfileTap;

  const NotificationsScreen({
    super.key,
    this.onHomeTap,
    this.onLeadsTap,
    this.onVisitsTap,
    this.onTasksTap,
    this.onProfileTap,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = "All";
  int _selectedBottomNavIndex = 0;

  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      NotificationItem(
        id: "1",
        title: "New lead assigned: Acme Corp",
        time: "2 hours ago",
        category: "leads",
        isUnread: true,
        icon: Icons.person_outline_rounded,
        iconColor: const Color(0xFF0F4C4C),
        iconBgColor: const Color(0xFFE0F2F1),
        actionText: "View Lead",
        onAction: () => _handleLeadTap("Acme Corp"),
      ),
      NotificationItem(
        id: "2",
        title: "Visit with TechVista in 30 min",
        time: "30 min ago",
        category: "visits",
        isUnread: true,
        icon: Icons.calendar_today_outlined,
        iconColor: const Color(0xFFD97706),
        iconBgColor: const Color(0xFFFEF3C7),
      ),
      NotificationItem(
        id: "3",
        title: "John at Acme opened your proposal",
        time: "1 hour ago",
        category: "leads",
        isUnread: true,
        icon: Icons.visibility_outlined,
        iconColor: const Color(0xFF2563EB),
        iconBgColor: const Color(0xFFDBEAFE),
      ),
      NotificationItem(
        id: "4",
        title: "Follow-up with DataFlow is due today",
        time: "3 hours ago",
        category: "tasks",
        isUnread: false,
        icon: Icons.error_outline_rounded,
        iconColor: const Color(0xFFD97706),
        iconBgColor: const Color(0xFFFEF3C7),
      ),
      NotificationItem(
        id: "5",
        title: "Deal moved to Negotiation",
        time: "Yesterday",
        category: "deals",
        isUnread: false,
        icon: Icons.handshake_outlined,
        iconColor: const Color(0xFF7C3AED),
        iconBgColor: const Color(0xFFEDE9FE),
      ),
    ];
  }

  int get _unreadCount => _notifications.where((item) => item.isUnread).length;

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isUnread: false)).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "All notifications marked as read",
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF0F4C4C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleLeadTap(String company) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Opening lead details for $company",
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF0F4C4C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleReadStatus(String id) {
    setState(() {
      _notifications = _notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isUnread: !n.isUnread);
        }
        return n;
      }).toList();
    });
  }

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilter == "Unread") {
      return _notifications.where((n) => n.isUnread).toList();
    } else if (_selectedFilter == "Leads") {
      return _notifications.where((n) => n.category == "leads").toList();
    } else if (_selectedFilter == "Visits") {
      return _notifications.where((n) => n.category == "visits").toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _unreadCount;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 1. Static Top Header (Title with Badge + "Mark All Read")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Notifications",
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "$unreadCount",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      GestureDetector(
                        onTap: _markAllAsRead,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                          child: Text(
                            "Mark All Read",
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F4C4C),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Filter Chips (All, Unread 5, Leads, Visits) - Invisible Scrollbar
                SizedBox(
                  height: 38,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                      children: [
                        _buildFilterChip("All", isSelected: _selectedFilter == "All"),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          "Unread",
                          badgeCount: unreadCount,
                          isSelected: _selectedFilter == "Unread",
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip("Leads", isSelected: _selectedFilter == "Leads"),
                        const SizedBox(width: 8),
                        _buildFilterChip("Visits", isSelected: _selectedFilter == "Visits"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Notification List Items - Scrollbars strictly hidden per requirement
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: _filteredNotifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No notifications in this tab",
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(
                              left: AppSpacing.screenHorizontal,
                              right: AppSpacing.screenHorizontal,
                              bottom: 110,
                            ),
                            itemCount: _filteredNotifications.length,
                            separatorBuilder: (context, index) => const Divider(
                              color: Color(0xFFF3F4F6),
                              thickness: 1,
                              height: 24,
                            ),
                            itemBuilder: (context, index) {
                              final item = _filteredNotifications[index];
                              return _buildNotificationRow(item);
                            },
                          ),
                  ),
                ),
              ],
            ),

            // Floating Bottom Navigation Bar (matches design system & screenshot)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildFloatingBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {int? badgeCount, required bool isSelected}) {
    final bool isAllSelected = isSelected;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: badgeCount != null ? 14 : 18,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: isAllSelected
              ? const Color(0xFFCCFBF1) // light teal/mint background
              : const Color(0xFFF3F4F6), // neutral background
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: isAllSelected ? FontWeight.w700 : FontWeight.w500,
                color: isAllSelected ? const Color(0xFF0F4C4C) : const Color(0xFF4B5563),
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  "$badgeCount",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationRow(NotificationItem item) {
    return GestureDetector(
      onTap: () => _toggleReadStatus(item.id),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Unread Dot Indicator (or aligned spacer)
            SizedBox(
              width: 14,
              child: item.isUnread
                  ? Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F4C4C), // Teal dot
                        shape: BoxShape.circle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(width: 4),

            // Circular Icon Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: item.iconColor,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // Content: Title & Subtitle/Timestamp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.time,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Optional Right Action Button (e.g. "View Lead")
            if (item.actionText != null) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: item.onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F4C4C),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F4C4C).withOpacity(0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    item.actionText!,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, "Home", onTap: widget.onHomeTap),
          _buildNavItem(1, Icons.folder_outlined, "Leads", onTap: widget.onLeadsTap),
          _buildNavItem(2, Icons.alt_route_rounded, "Visits", onTap: widget.onVisitsTap),
          _buildNavItem(3, Icons.format_list_bulleted_rounded, "Tasks", onTap: widget.onTasksTap),
          _buildNavItem(4, Icons.person_outline_rounded, "Profile", onTap: widget.onProfileTap),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {VoidCallback? onTap}) {
    final isSelected = _selectedBottomNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBottomNavIndex = index;
        });
        if (onTap != null) {
          onTap();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? const Color(0xFF0F4C4C) : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF0F4C4C) : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
