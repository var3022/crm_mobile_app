import "package:flutter/material.dart";
import "leads_list_screen.dart";
import "../models/lead_model.dart";

/// Leads Screen 2: Empty Leads Screen (`screen-empty-leads`)
/// This screen is displayed for new field agents who have not yet been assigned leads,
/// or whenever all leads are cleared/unassigned.
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
/// Matches the visual layout and interactions from image.png:
/// - Top App Bar: "Leads" title, circular Search button, circular '+' Add Lead button
/// - Filter Chips Row with count badges: All (0), New (0), Contacted (0), Qualified (0)
/// - Center Empty State: Pale mint circle illustration with clipboard checklist icon
/// - Title: "No Leads Yet" (22px bold, #111827)
/// - Subtitle: "Your assigned leads will appear here. You can also add leads manually or scan visiting cards."
/// - Primary Action Button: "+ Add New Lead" (solid #0F4C4C)
/// - Secondary Action Button: "Scan Visiting Card" (outline #0F4C4C with camera icon)
/// - Pinned Bottom Navigation Bar with 'Leads' tab actively highlighted
class ScreenEmptyLeads extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onAddLeadTap;
  final VoidCallback? onScanCardTap;
  final ValueChanged<LeadModel>? onLeadSelected;
  final ValueChanged<int>? onBottomNavTap;

  const ScreenEmptyLeads({
    super.key,
    this.onSearchTap,
    this.onAddLeadTap,
    this.onScanCardTap,
    this.onLeadSelected,
    this.onBottomNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return LeadsListScreen(
      startEmpty: true,
      onSearchTap: onSearchTap,
      onAddLeadTap: onAddLeadTap,
      onScanCardTap: onScanCardTap,
      onLeadSelected: onLeadSelected,
      onBottomNavTap: onBottomNavTap,
    );
  }
}
