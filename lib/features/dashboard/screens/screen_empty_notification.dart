import "package:flutter/material.dart";
import "notifications_screen.dart";

/// Dashboard & Notification Screen 3 - Empty Notification (`screen-empty-notification`)
/// This screen is displayed for new users without any notifications or when all notifications are cleared.
/// As mandated, it reuses the `NotificationsScreen` component with `startEmpty: true` rather than creating a separate duplicate component.
class EmptyNotificationScreen extends StatelessWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onLeadsTap;
  final VoidCallback? onVisitsTap;
  final VoidCallback? onTasksTap;
  final VoidCallback? onProfileTap;

  const EmptyNotificationScreen({
    super.key,
    this.onHomeTap,
    this.onLeadsTap,
    this.onVisitsTap,
    this.onTasksTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationsScreen(
      startEmpty: true,
      onHomeTap: onHomeTap,
      onLeadsTap: onLeadsTap,
      onVisitsTap: onVisitsTap,
      onTasksTap: onTasksTap,
      onProfileTap: onProfileTap,
    );
  }
}
