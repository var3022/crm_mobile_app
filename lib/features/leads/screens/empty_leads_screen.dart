import "package:flutter/material.dart";
import "leads_list_screen.dart";
import "../models/lead_model.dart";

/// Leads Screen 2: Empty Leads Screen (`screen-empty-leads`)
/// Reusable export class for the empty leads state.
class EmptyLeadsScreen extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onAddLeadTap;
  final VoidCallback? onScanCardTap;
  final ValueChanged<LeadModel>? onLeadSelected;
  final ValueChanged<int>? onBottomNavTap;
  final bool showBottomNav;

  const EmptyLeadsScreen({
    super.key,
    this.onSearchTap,
    this.onAddLeadTap,
    this.onScanCardTap,
    this.onLeadSelected,
    this.onBottomNavTap,
    this.showBottomNav = true,
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
      showBottomNav: showBottomNav,
    );
  }
}

typedef ScreenEmptyLeads = EmptyLeadsScreen;
