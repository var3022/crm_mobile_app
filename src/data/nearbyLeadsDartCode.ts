export const nearbyLeadsDartCode = `import "package:flutter/material.dart";
import "../models/lead_model.dart";
import "../widgets/distance_chip.dart";
import "../widgets/nearby_lead_card.dart";
import "../../../core/theme/app_colors.dart";

/// Leads Screen 2: Nearby Leads Screen (screen-nearby-leads)
/// Follows the CRM Pro Flutter/Dart master prompt and design system.
/// Matches the visual layout and interactions from image.png:
/// - Top Bar: "Nearby Leads" title + segmented toggle ("Map" | "List")
/// - Radius Filter Chips: "1 km", "2 km" (active), "5 km", "10 km"
/// - Custom Map Canvas: Illustrated South Mumbai area map with:
///   * "SOUTH MUMBAI" stencil banner
///   * Current user live location (blue dot with pulse ring)
///   * Custom lead callout markers ("Acme Corp" in red, "TechVista" in amber)
///   * Cluster marker badge ("5" in dark teal)
///   * Compass rose and scale indicator
/// - Section Header: "NEARBY LEADS (SORTED BY DISTANCE)"
/// - Distance-ranked cards:
///   * Distance badge (e.g. "0.8 km", "1.2 km", "2.5 km") in mint rounded rect
///   * Lead company name and last visit timestamp
///   * Action icon buttons: Call (phone) & Navigate/Detail (arrow)
/// - Floating bottom navigation bar with 'Leads' actively highlighted
class NearbyLeadsScreen extends StatefulWidget {
  final VoidCallback? onBackToLeadsList;
  final ValueChanged<LeadModel>? onLeadSelected;
  final ValueChanged<String>? onCallLead;
  final ValueChanged<LeadModel>? onNavigateRoute;
  final ValueChanged<int>? onBottomNavTap;

  const NearbyLeadsScreen({
    super.key,
    this.onBackToLeadsList,
    this.onLeadSelected,
    this.onCallLead,
    this.onNavigateRoute,
    this.onBottomNavTap,
  });

  @override
  State<NearbyLeadsScreen> createState() => _NearbyLeadsScreenState();
}

class _NearbyLeadsScreenState extends State<NearbyLeadsScreen> {
  // View mode: 'Map' or 'List'
  String _selectedViewMode = 'Map';

  // Selected distance radius filter: 1, 2, 5, or 10 km
  double _selectedRadiusKm = 2.0;

  // Active bottom nav index (1 = Leads)
  int _currentNavIndex = 1;

  // Selected lead id from map marker tap
  String? _selectedLeadId;

  // Demo nearby leads database
  late List<NearbyLeadData> _allNearbyLeads;

  @override
  void initState() {
    super.initState();
    _allNearbyLeads = [
      NearbyLeadData(
        id: 'lead-1',
        companyName: 'Acme Corp',
        contactName: 'John Doe',
        contactRole: 'CTO',
        distanceKm: 0.8,
        locationArea: 'Nariman Point, South Mumbai',
        lastVisit: 'Yesterday',
        phoneNumber: '+91 98201 12345',
        aiScore: 94,
        markerColor: const Color(0xFFEF4444), // Red callout marker
        mapPositionX: 0.42,
        mapPositionY: 0.28,
      ),
      NearbyLeadData(
        id: 'lead-2',
        companyName: 'TechVista Ltd',
        contactName: 'Priya Sharma',
        contactRole: 'HR Director',
        distanceKm: 1.2,
        locationArea: 'Lower Parel, South Mumbai',
        lastVisit: '3 days ago',
        phoneNumber: '+91 98192 98765',
        aiScore: 76,
        markerColor: const Color(0xFFF59E0B), // Amber callout marker
        mapPositionX: 0.72,
        mapPositionY: 0.35,
      ),
      NearbyLeadData(
        id: 'lead-5',
        companyName: 'Nova Pharmaceuticals',
        contactName: 'Dr. Rajesh Iyer',
        contactRole: 'Purchase Director',
        distanceKm: 0.9,
        locationArea: 'Worli Seaface',
        lastVisit: '4 days ago',
        phoneNumber: '+91 98401 88990',
        aiScore: 91,
        markerColor: const Color(0xFF10B981),
        mapPositionX: 0.50,
        mapPositionY: 0.45,
      ),
      NearbyLeadData(
        id: 'lead-4',
        companyName: 'Apex Logistics',
        contactName: 'Vikram Mehta',
        contactRole: 'VP Sales',
        distanceKm: 1.8,
        locationArea: 'BKC / Fort Commercial',
        lastVisit: '1 week ago',
        phoneNumber: '+91 98334 23456',
        aiScore: 88,
        markerColor: const Color(0xFF0F4C4C),
        mapPositionX: 0.35,
        mapPositionY: 0.50,
      ),
      NearbyLeadData(
        id: 'lead-3',
        companyName: 'DataFlow Systems',
        contactName: 'Karan Malhotra',
        contactRole: 'MD',
        distanceKm: 2.5,
        locationArea: 'Andheri / Girgaon',
        lastVisit: 'No recent visits',
        phoneNumber: '+91 98205 55678',
        aiScore: 45,
        markerColor: const Color(0xFF6B7280),
        mapPositionX: 0.20,
        mapPositionY: 0.36,
      ),
      NearbyLeadData(
        id: 'lead-6',
        companyName: 'Technology Solutions',
        contactName: 'Rajiv Sen',
        contactRole: 'Head of IT',
        distanceKm: 3.2,
        locationArea: 'Churchgate',
        lastVisit: '2 weeks ago',
        phoneNumber: '+91 98205 77890',
        aiScore: 78,
        markerColor: const Color(0xFF3B82F6),
        mapPositionX: 0.55,
        mapPositionY: 0.22,
      ),
    ];
  }

  List<NearbyLeadData> get _filteredLeads {
    final list = _allNearbyLeads
        .where((lead) => lead.distanceKm <= _selectedRadiusKm)
        .toList();
    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top App Bar: Title & Map/List Segmented Toggle
            _buildTopAppBar(),

            // 2. Radius Filter Chips Row (1 km, 2 km, 5 km, 10 km)
            _buildRadiusFilterRow(),

            const SizedBox(height: 8),

            // 3. Main Body: Split Map View or Full List View
            Expanded(
              child: _selectedViewMode == 'Map'
                  ? _buildMapViewWithList()
                  : _buildFullListView(),
            ),

            // 4. Floating Rounded Bottom Navigation Bar
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Nearby Leads",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          // Map | List Segmented Toggle
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                _buildSegmentButton("Map", _selectedViewMode == 'Map'),
                _buildSegmentButton("List", _selectedViewMode == 'List'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedViewMode = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F4C4C) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  Widget _buildRadiusFilterRow() {
    final radii = [1.0, 2.0, 5.0, 10.0];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: radii.map((km) {
          final isSelected = _selectedRadiusKm == km;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRadiusKm = km;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0F4C4C)
                      : const Color(0xFFE8F7F7),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0F4C4C).withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  "\${km.toInt()} km",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF0F4C4C),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMapViewWithList() {
    final leads = _filteredLeads;
    return Column(
      children: [
        // 3a. Illustrated South Mumbai Map Canvas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7EE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Map Background Vector Graphics
                  Positioned.fill(
                    child: CustomPaint(
                      painter: SouthMumbaiMapPainter(),
                    ),
                  ),

                  // "SOUTH MUMBAI" Stencil Title Banner
                  const Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "SOUTH MUMBAI",
                        style: TextStyle(
                          fontFamily: "Serif",
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.2,
                          color: Color(0xFF78716C),
                        ),
                      ),
                    ),
                  ),

                  // Current User Blue Glowing Position Indicator
                  Positioned(
                    left: 175,
                    top: 110,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 3,
                          )
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Marker 1: Acme Corp (Red Callout Pin)
                  Positioned(
                    left: 110,
                    top: 55,
                    child: _buildMapCalloutMarker(
                      title: "Acme Corp",
                      color: const Color(0xFFEF4444),
                      isSelected: _selectedLeadId == 'lead-1',
                      onTap: () {
                        setState(() {
                          _selectedLeadId = 'lead-1';
                        });
                      },
                    ),
                  ),

                  // Marker 2: TechVista (Amber Callout Pin)
                  Positioned(
                    left: 215,
                    top: 115,
                    child: _buildMapCalloutMarker(
                      title: "TechVista",
                      color: const Color(0xFFF59E0B),
                      isSelected: _selectedLeadId == 'lead-2',
                      onTap: () {
                        setState(() {
                          _selectedLeadId = 'lead-2';
                        });
                      },
                    ),
                  ),

                  // Marker 3: Cluster Count Badge ("5")
                  Positioned(
                    left: 55,
                    top: 120,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F4C4C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "5",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Scale & Compass Indicators
                  Positioned(
                    bottom: 8,
                    left: 12,
                    child: Row(
                      children: [
                        Container(width: 25, height: 1.5, color: const Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        const Text(
                          "1 km",
                          style: TextStyle(fontSize: 8.5, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    bottom: 8,
                    right: 12,
                    child: Icon(
                      Icons.navigation_outlined,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 3b. Section Title: NEARBY LEADS (SORTED BY DISTANCE)
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 6, bottom: 4),
          child: Row(
            children: [
              Text(
                "NEARBY LEADS (SORTED BY DISTANCE)",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Text(
                "(\${leads.length})",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),

        // 3c. Scrollable List of Lead Cards
        Expanded(
          child: leads.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: leads.length,
                  itemBuilder: (context, index) {
                    final lead = leads[index];
                    return _buildLeadCard(lead);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFullListView() {
    final leads = _filteredLeads;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Showing \${leads.length} leads within \${_selectedRadiusKm.toInt()} km",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
              const Text(
                "Sorted by Distance",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F4C4C),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: leads.length,
            itemBuilder: (context, index) {
              final lead = leads[index];
              return _buildLeadCard(lead);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapCalloutMarker({
    required String title,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Icon(
            Icons.location_on,
            size: 20,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(NearbyLeadData lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedLeadId == lead.id
              ? const Color(0xFF0F4C4C)
              : const Color(0xFFE5E7EB),
          width: _selectedLeadId == lead.id ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Distance Mint Chip (e.g. "0.8 km")
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFCCFBF1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "\${lead.distanceKm.toStringAsFixed(1)} km",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F4C4C),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Company Name & Last Visit Timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.companyName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lead.lastVisit.startsWith('Last visit')
                      ? lead.lastVisit
                      : "Last visit: \${lead.lastVisit}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Action 1: Call Button (Circular Mint)
          GestureDetector(
            onTap: () => widget.onCallLead?.call(lead.phoneNumber),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_outlined,
                size: 18,
                color: Color(0xFF0F4C4C),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Action 2: Navigate / Detail Arrow Button (Circular Mint)
          GestureDetector(
            onTap: () {
              // Open route or details
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFCCFBF1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: Color(0xFF0F4C4C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            "No leads found within \${_selectedRadiusKm.toInt()} km",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Try expanding your radius filter to 5 km or 10 km.",
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
              color: const Color(0xFF0F4C4C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    return GestureDetector(
      onTap: () => widget.onBottomNavTap?.call(index),
      child: Padding(
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
      ),
    );
  }
}

/// Data class for Nearby Lead representations
class NearbyLeadData {
  final String id;
  final String companyName;
  final String contactName;
  final String contactRole;
  final double distanceKm;
  final String locationArea;
  final String lastVisit;
  final String phoneNumber;
  final int aiScore;
  final Color markerColor;
  final double mapPositionX;
  final double mapPositionY;

  NearbyLeadData({
    required this.id,
    required this.companyName,
    required this.contactName,
    required this.contactRole,
    required this.distanceKm,
    required this.locationArea,
    required this.lastVisit,
    required this.phoneNumber,
    required this.aiScore,
    required this.markerColor,
    required this.mapPositionX,
    required this.mapPositionY,
  });
}

/// Custom Painter for the South Mumbai Map Illustration
class SouthMumbaiMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final landPaint = Paint()
      ..color = const Color(0xFFE9E5D9)
      ..style = PaintingStyle.fill;

    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final waterPaint = Paint()
      ..color = const Color(0xFFD6E8EE)
      ..style = PaintingStyle.fill;

    // Draw Sea Background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), waterPaint);

    // Draw South Mumbai Peninsula Contour
    final peninsulaPath = Path();
    peninsulaPath.moveTo(size.width * 0.15, 0);
    peninsulaPath.quadraticBezierTo(size.width * 0.25, size.height * 0.4, size.width * 0.45, size.height * 0.7);
    peninsulaPath.quadraticBezierTo(size.width * 0.55, size.height * 0.9, size.width * 0.75, size.height * 0.6);
    peninsulaPath.quadraticBezierTo(size.width * 0.9, size.height * 0.35, size.width * 0.85, 0);
    peninsulaPath.close();

    canvas.drawPath(peninsulaPath, landPaint);

    // Draw Roads Grid
    for (double i = 0.2; i <= 0.8; i += 0.15) {
      canvas.drawLine(
        Offset(size.width * i, size.height * 0.1),
        Offset(size.width * (i + 0.1), size.height * 0.75),
        roadPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
`;
