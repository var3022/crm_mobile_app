import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../features/dashboard/screens/dashboard_screen.dart";
import "../features/leads/screens/leads_list_screen.dart";
import "../features/visits/screens/visits_list_screen.dart";
import "app_bottom_nav_bar.dart";

/// Screen layout that hosts the persistent CRM Pro shell:
/// 1. **Main Section (`main sec`):** Renders the active screen (Dashboard, Leads, etc.) via [IndexedStack]
///    so state is preserved and transitions happen without reloading or layout shifts.
/// 2. **Bottom Section (`bottom sec`):** Renders the persistent [AppBottomNavBar].
///    The navigation bar stays completely stationary and only moves the active highlight.
class MainLayoutScreen extends StatefulWidget {
  final int initialIndex;
  final ValueChanged<int>? onNavTap;

  const MainLayoutScreen({
    super.key,
    this.initialIndex = 0,
    this.onNavTap,
  });

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant MainLayoutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onNavTap?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // Tab 0: Home / Dashboard
            DashboardScreen(
              showBottomNav: false,
              onNotificationTap: () {
                Navigator.of(context).pushNamed("/notifications");
              },
              onNavTap: _onTabSelected,
            ),

            // Tab 1: Leads
            LeadsListScreen(
              showBottomNav: false,
              onBottomNavTap: _onTabSelected,
            ),

            // Tab 2: Visits
            VisitsListScreen(
              showBottomNav: false,
              onBottomNavTap: _onTabSelected,
              onViewNearbyLeadsTap: () => _onTabSelected(1),
            ),

            // Tab 3: Tasks
            _buildPlaceholderTab(
              title: "Tasks",
              subtitle: "Follow-ups, client tasks, and deadline reminders.",
              icon: Icons.format_list_bulleted_rounded,
            ),

            // Tab 4: Profile
            _buildPlaceholderTab(
              title: "Profile & Settings",
              subtitle: "Sales agent profile, territory preferences, and offline settings.",
              icon: Icons.manage_accounts_rounded,
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }

  Widget _buildPlaceholderTab({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4F2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                size: 38,
                color: const Color(0xFF0F4C4C),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A reusable layout wrapper for individual custom screens.
class MainLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int>? onNavTap;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final PreferredSizeWidget? appBar;
  final Color backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool useSafeArea;
  final bool safeAreaBottom;

  const MainLayout({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.onNavTap,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.appBar,
    this.backgroundColor = Colors.white,
    this.resizeToAvoidBottomInset = true,
    this.useSafeArea = true,
    this.safeAreaBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget mainContent = child;

    if (useSafeArea) {
      mainContent = SafeArea(
        bottom: safeAreaBottom,
        child: mainContent,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: mainContent,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: onNavTap,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

typedef ScreenMainLayout = MainLayoutScreen;
typedef AppLayout = MainLayout;
