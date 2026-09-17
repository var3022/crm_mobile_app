export const leadsListDartCode = `import "package:flutter/material.dart";
import "../models/lead_model.dart";
import "../widgets/lead_card.dart";
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
  final VoidCallback? onSearchTap;
  final VoidCallback? onAddLeadTap;
  final ValueChanged<LeadModel>? onLeadSelected;
  final ValueChanged<int>? onBottomNavTap;

  const LeadsListScreen({
    super.key,
    this.onSearchTap,
    this.onAddLeadTap,
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

  late List<LeadModel> _leads;

  @override
  void initState() {
    super.initState();
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
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LeadModel> get _filteredLeads {
    List<LeadModel> list = List.from(_leads);

    if (_selectedFilter == 'New') {
      list = list.where((l) => l.stage == LeadStage.newLead).toList();
    } else if (_selectedFilter == 'Contacted') {
      list = list.where((l) => l.stage == LeadStage.contacted).toList();
    } else if (_selectedFilter == 'Qualified') {
      list = list.where((l) => l.stage == LeadStage.qualified).toList();
    } else if (_selectedFilter == 'Hot') {
      list = list.where((l) => l.temperature == LeadTemperature.hot).toList();
    } else if (_selectedFilter == 'Follow-up Due') {
      list = list.where((l) => l.notes.contains('Follow-up') || l.temperature == LeadTemperature.cold || l.companyName == 'DataFlow Systems').toList();
    } else if (_selectedFilter == 'Nearby') {
      list = list.where((l) => l.distanceKm <= 1.0).toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((l) {
        return l.companyName.toLowerCase().contains(query) ||
            l.contactName.toLowerCase().contains(query) ||
            l.locationArea.toLowerCase().contains(query);
      }).toList();
    }

    if (_currentSort == 'AI Score') {
      list.sort((a, b) => b.aiScore.compareTo(a.aiScore));
    } else if (_currentSort == 'Distance') {
      list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } else if (_currentSort == 'Company Name') {
      list.sort((a, b) => a.companyName.compareTo(b.companyName));
    }

    return list;
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
            // Top Header: Title "Leads" + Search & Add Icons
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
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
                      // Search Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSearchOpen = !_isSearchOpen;
                            if (!_isSearchOpen) _searchController.clear();
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isSearchOpen ? const Color(0xFFE8F7F7) : Colors.white,
                            border: Border.all(
                              color: _isSearchOpen ? const Color(0xFF0F4C4C) : const Color(0xFFE5E7EB),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: _isSearchOpen ? const Color(0xFF0F4C4C) : const Color(0xFF111827),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Add Lead Button
                      GestureDetector(
                        onTap: () {},
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

            // Filter Chips Row
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFilterChip('All', isSelected: _selectedFilter == 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('New', count: _leads.where((l) => l.stage == LeadStage.newLead).length, isSelected: _selectedFilter == 'New'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Contacted', isSelected: _selectedFilter == 'Contacted'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Qualified', isSelected: _selectedFilter == 'Qualified'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Hot 🔥', filterKey: 'Hot', isSelected: _selectedFilter == 'Hot'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Follow-up Due', isSelected: _selectedFilter == 'Follow-up Due'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Nearby 📍', filterKey: 'Nearby', isSelected: _selectedFilter == 'Nearby'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Sub-header: "Showing 120 leads" & "Sorted by AI Score ▼"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Showing 120 leads",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
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

            // Scrollable Leads List
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: leads.length,
                itemBuilder: (context, index) {
                  final lead = leads[index];
                  return LeadCard(
                    lead: lead,
                    onTap: () {},
                  );
                },
              ),
            ),

            // Bottom Navigation Bar with active 'Leads' indicator
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {String? filterKey, int? count, required bool isSelected}) {
    final key = filterKey ?? label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
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
              const SizedBox(width: 5),
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  "$count",
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, "Home", Icons.home_outlined),
          _buildActiveNavItem(1, "Leads", Icons.folder_rounded),
          _buildNavItem(2, "Visits", Icons.share_location_outlined),
          _buildNavItem(3, "Tasks", Icons.format_list_bulleted_outlined),
          _buildNavItem(4, "Profile", Icons.manage_accounts_outlined),
        ],
      ),
    );
  }

  Widget _buildActiveNavItem(int index, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0F4C4C)),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F4C4C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
`;
