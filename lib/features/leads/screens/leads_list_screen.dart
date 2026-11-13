import "package:flutter/material.dart";
import "../models/lead_model.dart";
import "../widgets/lead_card.dart";
// ignore: unused_import
import "../../../core/theme/app_colors.dart";

/// Leads Screen 1: Leads List Screen (screen-leads-list)
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
/// Matches the visual layout and interactions from image.png:
/// - Top App Bar: "Leads" title, circular Search button, circular '+' Add Lead button
/// - Filter Chips Row: All, New (with badge 3), Contacted, Qualified, Hot, Cold
/// - Sub-header: "Showing 120 leads", "Sorted by AI Score ▼"
/// - Cards List with high-contrast AI Score circles (94, 76, 45), contact details,
///   location, timestamps, status pills (Hot, Contacted, Cold), and swipe hints
/// - Interactive Swipe Left to Call, Swipe Right to Log Visit
/// - Pinned Bottom Navigation Bar with 'Leads' tab actively highlighted
class LeadsListScreen extends StatefulWidget {
  final bool startEmpty;
  final VoidCallback? onSearchTap;
  final VoidCallback? onAddLeadTap;
  final VoidCallback? onScanCardTap;
  final ValueChanged<LeadModel>? onLeadSelected;
  final ValueChanged<int>? onBottomNavTap;

  const LeadsListScreen({
    super.key,
    this.startEmpty = false,
    this.onSearchTap,
    this.onAddLeadTap,
    this.onScanCardTap,
    this.onLeadSelected,
    this.onBottomNavTap,
  });

  @override
  State<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends State<LeadsListScreen> {
  int _currentNavIndex = 1; // Leads tab active
  String _selectedFilter = 'All';
  String _currentSort = 'AI Score';
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  // Mock leads matching image.png and field sales workflow
  late List<LeadModel> _leads;

  @override
  void initState() {
    super.initState();
    if (widget.startEmpty) {
      _leads = [];
    } else {
      _leads = [
        const LeadModel(
          id: 'lead-1',
          companyName: 'Acme Corp',
          contactName: 'John Doe',
          contactRole: 'CTO',
          distanceKm: 0.8,
          locationArea: 'South Mumbai',
          lastActive: '2 hours ago',
          aiScore: 94,
          stage: LeadStage.qualified,
          temperature: LeadTemperature.hot,
          isFlagged: true,
          phoneNumber: '+91 98201 12345',
          email: 'john.doe@acmecorp.com',
          hasSwipeActionTip: true,
          notes: 'Interested in enterprise fleet tracking integration.',
        ),
        const LeadModel(
          id: 'lead-2',
          companyName: 'TechVista Ltd',
          contactName: 'Priya Sharma',
          contactRole: 'HR',
          distanceKm: 1.2,
          locationArea: 'Lower Parel',
          lastActive: 'Yesterday',
          aiScore: 76,
          stage: LeadStage.contacted,
          temperature: LeadTemperature.warm,
          isFlagged: false,
          phoneNumber: '+91 98192 98765',
          email: 'priya.sharma@techvista.io',
          hasSwipeActionTip: false,
          notes: 'Follow up regarding cloud licenses next week.',
        ),
        const LeadModel(
          id: 'lead-3',
          companyName: 'DataFlow Systems',
          contactName: 'Karan Malhotra',
          contactRole: 'MD',
          distanceKm: 2.5,
          locationArea: 'Andheri East',
          lastActive: '3 days ago',
          aiScore: 45,
          stage: LeadStage.newLead,
          temperature: LeadTemperature.cold,
          isFlagged: false,
          phoneNumber: '+91 98205 55678',
          email: 'karan@dataflow.co.in',
          hasSwipeActionTip: false,
          notes: 'Cold inbound inquiry; schedule intro deck presentation.',
        ),
        const LeadModel(
          id: 'lead-4',
          companyName: 'Apex Logistics',
          contactName: 'Vikram Mehta',
          contactRole: 'VP Sales',
          distanceKm: 1.8,
          locationArea: 'BKC',
          lastActive: '5 hours ago',
          aiScore: 88,
          stage: LeadStage.qualified,
          temperature: LeadTemperature.hot,
          isFlagged: false,
          phoneNumber: '+91 98334 23456',
          email: 'vikram.m@apexlogistics.com',
          hasSwipeActionTip: false,
          notes: 'Ready for commercial proposal review.',
        ),
        const LeadModel(
          id: 'lead-5',
          companyName: 'Nova Pharmaceuticals',
          contactName: 'Dr. Rajesh Iyer',
          contactRole: 'Director',
          distanceKm: 0.6,
          locationArea: 'Worli',
          lastActive: 'Just now',
          aiScore: 92,
          stage: LeadStage.newLead,
          temperature: LeadTemperature.hot,
          isFlagged: true,
          phoneNumber: '+91 98401 88990',
          email: 'rajesh.iyer@novapharma.org',
          hasSwipeActionTip: false,
          notes: 'High priority doctor network dispatch trial.',
        ),
        const LeadModel(
          id: 'lead-6',
          companyName: 'Zenith Retail',
          contactName: 'Ananya Deshmukh',
          contactRole: 'Procurement Head',
          distanceKm: 3.1,
          locationArea: 'Dadar',
          lastActive: '1 day ago',
          aiScore: 64,
          stage: LeadStage.contacted,
          temperature: LeadTemperature.warm,
          isFlagged: false,
          phoneNumber: '+91 98210 77123',
          email: 'ananya@zenithretail.in',
          hasSwipeActionTip: false,
          notes: 'Requested sample barcode terminals.',
        ),
      ];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter and sort logic
  List<LeadModel> get _filteredLeads {
    List<LeadModel> list = List.from(_leads);

    // Apply Filter Chips
    if (_selectedFilter == 'New') {
      list = list.where((l) => l.stage == LeadStage.newLead).toList();
    } else if (_selectedFilter == 'Contacted') {
      list = list.where((l) => l.stage == LeadStage.contacted).toList();
    } else if (_selectedFilter == 'Qualified') {
      list = list.where((l) => l.stage == LeadStage.qualified).toList();
    } else if (_selectedFilter == 'Hot') {
      list = list.where((l) => l.temperature == LeadTemperature.hot).toList();
    } else if (_selectedFilter == 'Follow-up Due') {
      list = list
          .where(
            (l) =>
                (l.notes?.contains('Follow-up') ?? false) ||
                l.temperature == LeadTemperature.cold ||
                l.companyName == 'DataFlow Systems',
          )
          .toList();
    } else if (_selectedFilter == 'Nearby') {
      list = list.where((l) => l.distanceKm <= 1.0).toList();
    }

    // Apply Search Query
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((l) {
        return l.companyName.toLowerCase().contains(query) ||
            l.contactName.toLowerCase().contains(query) ||
            l.locationArea.toLowerCase().contains(query);
      }).toList();
    }

    // Apply Sorting
    if (_currentSort == 'AI Score') {
      list.sort((a, b) => b.aiScore.compareTo(a.aiScore));
    } else if (_currentSort == 'Distance') {
      list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } else if (_currentSort == 'Company Name') {
      list.sort((a, b) => a.companyName.compareTo(b.companyName));
    }

    return list;
  }

  void _toggleFlag(String id) {
    setState(() {
      _leads = _leads.map((lead) {
        if (lead.id == id) {
          return lead.copyWith(isFlagged: !lead.isFlagged);
        }
        return lead;
      }).toList();
    });
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Sort Leads By",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              ...['AI Score', 'Distance', 'Company Name'].map((sortOption) {
                final isSelected = _currentSort == sortOption;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    sortOption,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF0F4C4C)
                          : const Color(0xFF374151),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF0F4C4C),
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _currentSort = sortOption;
                    });
                    Navigator.of(ctx).pop();
                  },
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showAddLeadModal() {
    final companyCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final areaCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Add New Field Lead",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: companyCtrl,
                  decoration: InputDecoration(
                    labelText: "Company Name",
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: contactCtrl,
                        decoration: InputDecoration(
                          labelText: "Contact Name",
                          labelStyle: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: roleCtrl,
                        decoration: InputDecoration(
                          labelText: "Role / Designation",
                          labelStyle: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: areaCtrl,
                  decoration: InputDecoration(
                    labelText: "Location / Territory Area",
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (companyCtrl.text.trim().isNotEmpty) {
                        setState(() {
                          _leads.insert(
                            0,
                            LeadModel(
                              id: 'lead-${DateTime.now().millisecondsSinceEpoch}',
                              companyName: companyCtrl.text.trim(),
                              contactName: contactCtrl.text.trim().isEmpty
                                  ? 'Contact'
                                  : contactCtrl.text.trim(),
                              contactRole: roleCtrl.text.trim().isEmpty
                                  ? 'Lead'
                                  : roleCtrl.text.trim(),
                              distanceKm: 1.5,
                              locationArea: areaCtrl.text.trim().isEmpty
                                  ? 'Mumbai'
                                  : areaCtrl.text.trim(),
                              lastActive: 'Just now',
                              aiScore: 82,
                              stage: LeadStage.newLead,
                              temperature: LeadTemperature.warm,
                              phoneNumber: '+91 98000 00000',
                              email: 'info@lead.com',
                            ),
                          );
                        });
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Added ${companyCtrl.text.trim()} to leads",
                            ),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4C4C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Save Lead",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _callLead(LeadModel lead) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.phone_in_talk_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text("Calling ${lead.contactName} (${lead.phoneNumber})..."),
          ],
        ),
        backgroundColor: const Color(0xFF0F4C4C),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _logVisit(LeadModel lead) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text("Logged in-person visit for ${lead.companyName}!"),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leads = _filteredLeads;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top Header: Title "Leads" + Search & Add Icons
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Leads",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -0.6,
                    ),
                  ),
                  Row(
                    children: [
                      // Search Button (Circular white with border)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSearchOpen = !_isSearchOpen;
                            if (!_isSearchOpen) _searchController.clear();
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isSearchOpen
                                ? const Color(0xFFE8F7F7)
                                : Colors.white,
                            border: Border.all(
                              color: _isSearchOpen
                                  ? const Color(0xFF0F4C4C)
                                  : const Color(0xFFE5E7EB),
                              width: 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: _isSearchOpen
                                ? const Color(0xFF0F4C4C)
                                : const Color(0xFF111827),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Add Lead Button (Circular solid primary teal)
                      GestureDetector(
                        onTap: _showAddLeadModal,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF0F4C4C),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Optional Search Input field (if toggled)
            if (_isSearchOpen)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Search company, contact, or area...",
                    hintStyle: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF9CA3AF),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 18,
                      color: Color(0xFF0F4C4C),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFF6B7280),
                            ),
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F4C4C),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 6),

            // 2. Filter Chips Row (Horizontal Scroll)
            SizedBox(
              height: 38,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFilterChip(
                      'All',
                      count: _leads.length,
                      isSelected: _selectedFilter == 'All',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'New',
                      count: _leads
                          .where((l) => l.stage == LeadStage.newLead)
                          .length,
                      isSelected: _selectedFilter == 'New',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Contacted',
                      count: _leads
                          .where((l) => l.stage == LeadStage.contacted)
                          .length,
                      isSelected: _selectedFilter == 'Contacted',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Qualified',
                      count: _leads
                          .where((l) => l.stage == LeadStage.qualified)
                          .length,
                      isSelected: _selectedFilter == 'Qualified',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Hot 🔥',
                      filterKey: 'Hot',
                      count: _leads
                          .where((l) => l.temperature == LeadTemperature.hot)
                          .length,
                      isSelected: _selectedFilter == 'Hot',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Follow-up Due',
                      count: _leads
                          .where(
                            (l) =>
                                (l.notes?.contains('Follow-up') ?? false) ||
                                l.temperature == LeadTemperature.cold ||
                                l.companyName == 'DataFlow Systems',
                          )
                          .length,
                      isSelected: _selectedFilter == 'Follow-up Due',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Nearby 📍',
                      filterKey: 'Nearby',
                      count: _leads.where((l) => l.distanceKm <= 1.0).length,
                      isSelected: _selectedFilter == 'Nearby',
                    ),
                  ],
                ),
              ),
            ),

            // 3. Main Content: Empty State OR Leads List
            if (leads.isEmpty)
              _buildEmptyState()
            else ...[
              const SizedBox(height: 12),

              // Sub-header: "Showing X leads" & "Sorted by AI Score ▼"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Showing ${leads.length} leads",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showSortModal,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Sorted by $_currentSort",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F4C4C),
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xFF0F4C4C),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Scrollable Leads List with hidden scrollbars
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 4,
                      bottom: 12,
                    ),
                    itemCount: leads.length,
                    itemBuilder: (context, index) {
                      final lead = leads[index];
                      return LeadCard(
                        lead: lead,
                        onTap: () {
                          widget.onLeadSelected?.call(lead);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Selected ${lead.companyName}"),
                              duration: const Duration(milliseconds: 800),
                            ),
                          );
                        },
                        onCall: () => _callLead(lead),
                        onLogVisit: () => _logVisit(lead),
                        onToggleFlag: () => _toggleFlag(lead.id),
                      );
                    },
                  ),
                ),
              ),
            ],

            // 4. Bottom Navigation Bar with active 'Leads' tab indicator
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  /// Empty State View matching image.png exactly
  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pale mint circular container with custom clipboard checklist icon
              Container(
                width: 124,
                height: 124,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F7F7),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(44, 48),
                    painter: _ClipboardChecklistPainter(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Heading
              const Text(
                "No Leads Yet",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),

              // Explanatory Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Your assigned leads will appear here. You can also add leads manually or scan visiting cards.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action 1: Add New Lead Button (Primary solid teal)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onAddLeadTap?.call();
                    _showAddLeadModal();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C4C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Add New Lead",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action 2: Scan Visiting Card Button (Outlined teal with camera icon)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    widget.onScanCardTap?.call();
                    _showScanVisitingCardModal();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F4C4C),
                    side: const BorderSide(
                      color: Color(0xFF0F4C4C),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 20,
                        color: Color(0xFF0F4C4C),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Scan Visiting Card",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F4C4C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Visiting card scanner simulation modal with AI OCR detection
  void _showScanVisitingCardModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF0F4C4C),
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Scan Visiting Card",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0F4C4C), width: 2),
                ),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF10B981),
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "AI OCR Detected",
                            style: TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Apex Solutions Ltd.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Rajesh Sharma • VP Procurement",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        "+91 98211 44556 • Bandra Kurla Complex",
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _leads.insert(
                        0,
                        const LeadModel(
                          id: 'scanned-1',
                          companyName: 'Apex Solutions Ltd.',
                          contactName: 'Rajesh Sharma',
                          contactRole: 'VP Procurement',
                          distanceKm: 0.5,
                          locationArea: 'Bandra Kurla Complex',
                          lastActive: 'Just now (Scanned)',
                          aiScore: 92,
                          stage: LeadStage.newLead,
                          temperature: LeadTemperature.hot,
                          phoneNumber: '+91 98211 44556',
                          email: 'r.sharma@apexsolutions.in',
                          notes: 'Scanned from visiting card via AI OCR.',
                        ),
                      );
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Scanned card added to Leads!"),
                        backgroundColor: Color(0xFF0F4C4C),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C4C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Confirm & Add Scanned Lead",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Individual filter chip pill matching image.png
  Widget _buildFilterChip(
    String label, {
    String? filterKey,
    int? count,
    required bool isSelected,
  }) {
    final key = filterKey ?? label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = key;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F4C4C) : const Color(0xFFE8F7F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF0F4C4C),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0x33000000) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$count",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF0F4C4C),
                    height: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 5-item Bottom Navigation Bar with Leads (index 1) actively highlighted
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
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
              if (widget.onBottomNavTap != null) {
                widget.onBottomNavTap!(index);
              } else if (index == 0) {
                Navigator.of(context).pushReplacementNamed("/dashboard");
              }
            },
            behavior: HitTestBehavior.opaque,
            child: isActive
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
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
                          size: 20,
                          color: const Color(0xFF0F4C4C),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F4C4C),
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.outlinedIcon,
                          size: 20,
                          color: const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9CA3AF),
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

/// Custom painter rendering the clipboard checklist icon matching image.png exactly
class _ClipboardChecklistPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFF0F4C4C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF0F4C4C)
      ..style = PaintingStyle.fill;

    // Clipboard body (rounded rectangle)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.14,
        size.width * 0.76,
        size.height * 0.82,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, strokePaint);

    // Top clip: rounded arch
    final clipPath = Path();
    clipPath.moveTo(size.width * 0.35, size.height * 0.14);
    clipPath.lineTo(size.width * 0.35, size.height * 0.08);
    clipPath.arcToPoint(
      Offset(size.width * 0.65, size.height * 0.08),
      radius: Radius.circular(size.width * 0.15),
    );
    clipPath.lineTo(size.width * 0.65, size.height * 0.14);
    canvas.drawPath(clipPath, strokePaint);

    // Checklist items: 3 rows, each with a bullet dot and horizontal line
    final rowY = [size.height * 0.34, size.height * 0.52, size.height * 0.70];
    for (final y in rowY) {
      // Bullet dot
      canvas.drawCircle(Offset(size.width * 0.30, y), 2.2, fillPaint);
      // Horizontal line
      canvas.drawLine(
        Offset(size.width * 0.40, y),
        Offset(size.width * 0.72, y),
        strokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
