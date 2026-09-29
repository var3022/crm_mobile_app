import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../models/visit_model.dart";
import "../widgets/visit_card.dart";
import "empty_visits_screen.dart";
import "../../../layout/app_bottom_nav_bar.dart";
import "../repositories/visits_repository.dart";

/// Day item data structure for the weekly calendar day selector strip
class _CalendarDayData {
  final String dayName;
  final int dayNumber;
  final bool hasVisits;

  const _CalendarDayData({
    required this.dayName,
    required this.dayNumber,
    required this.hasVisits,
  });
}

/// Visits Screen 1: Visits List Screen (`screen-visits-list`)
/// Follows CRM Pro Flutter/Dart design system and matches Screenshot 1 & 2:
/// - Pinned Top Header: "Visits" title, circular Calendar button, circular '+' Add button
/// - Horizontal 7-day Week Strip (Mon 5 to Sun 11) with dot indicators
/// - Segmented Tab Toggle ("List View" vs "Map View")
/// - Completion Metric Banner ("3/6 visits Completed · ⏱ 2h 15m · 📍 18 km")
/// - Interactive Timeline Stepper with high-contrast status cards
/// - Empty state seamlessly embedded matching Screenshot 1
class VisitsListScreen extends StatefulWidget {
  final bool startEmpty;
  final VoidCallback? onScheduleVisitTap;
  final VoidCallback? onViewNearbyLeadsTap;
  final ValueChanged<int>? onBottomNavTap;
  final bool showBottomNav;

  const VisitsListScreen({
    super.key,
    this.startEmpty = false,
    this.onScheduleVisitTap,
    this.onViewNearbyLeadsTap,
    this.onBottomNavTap,
    this.showBottomNav = true,
  });

  @override
  State<VisitsListScreen> createState() => _VisitsListScreenState();
}

class _VisitsListScreenState extends State<VisitsListScreen> {
  int _selectedDay = 8; // Default Thursday 8th
  int _selectedViewIndex = 0; // 0: List View, 1: Map View
  int _currentNavIndex = 2; // Visits tab active

  final List<_CalendarDayData> _weekDays = const [
    _CalendarDayData(dayName: "Mon", dayNumber: 5, hasVisits: true),
    _CalendarDayData(dayName: "Tue", dayNumber: 6, hasVisits: false),
    _CalendarDayData(dayName: "Wed", dayNumber: 7, hasVisits: true),
    _CalendarDayData(dayName: "Thu", dayNumber: 8, hasVisits: true),
    _CalendarDayData(dayName: "Fri", dayNumber: 9, hasVisits: true),
    _CalendarDayData(dayName: "Sat", dayNumber: 10, hasVisits: false),
    _CalendarDayData(dayName: "Sun", dayNumber: 11, hasVisits: false),
  ];

  late List<VisitModel> _visits;
  final VisitsRepository _repository = VisitsRepository();

  @override
  void initState() {
    super.initState();
    if (widget.startEmpty) {
      _visits = [];
    } else {
      _visits = [];
      _loadVisits();
    }
  }

  Future<void> _loadVisits() async {


    try {
      final models = await _repository.getVisits();
      if (!mounted) return;
      setState(() {
        _visits = models;
        if (_visits.isEmpty) {
          _visits = _getDefaultVisits();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _visits = _getDefaultVisits();
      });
    }
  }

  List<VisitModel> _getDefaultVisits() {
    return [
      const VisitModel(
        id: "visit-1",
        time: "10:00 AM",
        status: VisitStatus.completed,
        meetingType: "First Meeting",
        companyName: "Acme Corp",
        contactName: "John Doe",
        contactRole: "CTO",
        locationAddress: "Nariman Point, South Mumbai",
        dayOfMonth: 8,
        distanceKm: 0.8,
        duration: "45m",
        notes: "Introductory presentation completed. Client requested cloud fleet proposal.",
      ),
      const VisitModel(
        id: "visit-2",
        time: "11:30 AM",
        status: VisitStatus.inProgress,
        meetingType: "Follow-up",
        companyName: "TechVista Solutions",
        contactName: "Priya Sharma",
        contactRole: "HR Director",
        locationAddress: "Lower Parel, Mumbai",
        dayOfMonth: 8,
        distanceKm: 1.2,
        duration: "In progress",
        notes: "Discuss employee tracking licenses and enterprise SLA terms.",
      ),
      const VisitModel(
        id: "visit-3",
        time: "02:00 PM",
        status: VisitStatus.upcoming,
        meetingType: "Demo",
        companyName: "DataFlow Inc",
        contactName: "Karan Malhotra",
        contactRole: "MD",
        locationAddress: "Andheri East, Mumbai",
        dayOfMonth: 8,
        distanceKm: 3.4,
        duration: "1 hour",
        notes: "Hardware terminal live demonstration and barcode scanner compatibility.",
      ),
    ];
  }

  List<VisitModel> get _currentDayVisits {
    return _visits.where((v) => v.dayOfMonth == _selectedDay).toList();
  }

  void _openScheduleVisitScreen() async {
    if (widget.onScheduleVisitTap != null) {
      widget.onScheduleVisitTap!();
      return;
    }
    final result = await Navigator.of(context).pushNamed("/schedule-visit");
    if (result is VisitModel) {
      setState(() {
        _visits.insert(0, result);
      });
    }
  }


  void _handlePrimaryAction(VisitModel visit) async {
    if (visit.status == VisitStatus.inProgress) {
      // Checkout current visit
      try {
        await _repository.checkout(visit.id);
      } catch (e) {
        // Handle checkout failure silently
      }

      setState(() {
        _visits = _visits.map((v) {
          if (v.id == visit.id) {
            return v.copyWith(status: VisitStatus.completed);
          }
          return v;
        }).toList();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text("Completed visit for ${visit.companyName}!"),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } else {
      _showVisitDetailsModal(visit);
    }
  }

  void _showVisitDetailsModal(VisitModel visit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    visit.companyName,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      visit.meetingType,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F4C4C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Contact: ${visit.contactName} (${visit.contactRole})",
                style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 6),
              Text(
                "Address: ${visit.locationAddress}",
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              if (visit.notes != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    visit.notes!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF374151),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentVisits = _currentDayVisits;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top Header: Title "Visits" + Calendar & Add Icons
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
                  Text(
                    "Visits",
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                      letterSpacing: -0.6,
                    ),
                  ),
                  Row(
                    children: [
                      // Calendar button (Circular white with border)
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2026, 8, 8),
                            firstDate: DateTime(2026, 1, 1),
                            lastDate: DateTime(2026, 12, 31),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDay = picked.day;
                            });
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            size: 19,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Add Visit Button (Circular deep teal)
                      GestureDetector(
                        onTap: _openScheduleVisitScreen,
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

            const SizedBox(height: 8),

            // 2. Horizontal Week Day Strip (Mon 5 to Sun 11)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _weekDays.map((day) {
                  final isSelected = _selectedDay == day.dayNumber;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDay = day.dayNumber;
                      });
                    },
                    child: Container(
                      width: 44,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0F4C4C)
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0F4C4C)
                              : const Color(0xFFF3F4F6),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            day.dayName,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${day.dayNumber}",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Dot indicator if day has visits
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: day.hasVisits
                                  ? (isSelected
                                      ? Colors.white
                                      : const Color(0xFF0F4C4C))
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            // 3. Segmented Control Switch: "List View" vs "Map View"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedViewIndex = 0;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedViewIndex == 0
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: _selectedViewIndex == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "List View",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: _selectedViewIndex == 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedViewIndex == 0
                                  ? const Color(0xFF0F4C4C)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedViewIndex = 1;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedViewIndex == 1
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: _selectedViewIndex == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Map View",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: _selectedViewIndex == 1
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedViewIndex == 1
                                  ? const Color(0xFF0F4C4C)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 4. Main Section: Empty Visits View OR Visits Timeline List View
            Expanded(
              child: currentVisits.isEmpty
                  ? EmptyVisitsScreen(
                      onScheduleVisit: _openScheduleVisitScreen,
                      onViewNearbyLeads: () {
                        widget.onViewNearbyLeadsTap?.call();
                        Navigator.of(context).pushReplacementNamed("/leads-list");
                      },
                    )
                  : ScrollConfiguration(
                      behavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(scrollbars: false),
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          // Completed Summary Banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFBF1), // Soft mint
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "3/6 visits Completed",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F4C4C),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "·",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F4C4C),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text("⏱", style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 4),
                                Text(
                                  "2h 15m",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F4C4C),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "·",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F4C4C),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text("📍", style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 4),
                                Text(
                                  "18 km",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F4C4C),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Timeline Stepper Cards
                          ...List.generate(currentVisits.length, (index) {
                            final visit = currentVisits[index];
                            return VisitCard(
                              visit: visit,
                              isFirst: index == 0,
                              isLast: index == currentVisits.length - 1,
                              onPrimaryAction: () => _handlePrimaryAction(visit),
                              onTap: () => _showVisitDetailsModal(visit),
                            );
                          }),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
            ),

            // Standalone Bottom Nav Bar (if rendered outside MainLayout)
            if (widget.showBottomNav)
              AppBottomNavBar(
                currentIndex: _currentNavIndex,
                onTap: (index) {
                  setState(() {
                    _currentNavIndex = index;
                  });
                  if (widget.onBottomNavTap != null) {
                    widget.onBottomNavTap!(index);
                  } else {
                    if (index == 0) {
                      Navigator.of(context).pushReplacementNamed("/dashboard");
                    } else if (index == 1) {
                      Navigator.of(context).pushReplacementNamed("/leads-list");
                    } else if (index == 2) {
                      Navigator.of(context).pushReplacementNamed("/visits");
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

typedef ScreenVisitsList = VisitsListScreen;
