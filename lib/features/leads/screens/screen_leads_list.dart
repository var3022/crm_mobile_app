import "package:flutter/material.dart";
import "leads_list_screen.dart";
import "../models/lead_model.dart";

/// Alias wrapper for Screen 1: Leads List (screen-leads-list)
class ScreenLeadsList extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onAddLeadTap;
  final ValueChanged<LeadModel>? onLeadSelected;
  final ValueChanged<int>? onBottomNavTap;

  const ScreenLeadsList({
    super.key,
    this.onSearchTap,
    this.onAddLeadTap,
    this.onLeadSelected,
    this.onBottomNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return LeadsListScreen(
      onSearchTap: onSearchTap,
      onAddLeadTap: onAddLeadTap,
      onLeadSelected: onLeadSelected,
      onBottomNavTap: onBottomNavTap,
    );
  }
}
