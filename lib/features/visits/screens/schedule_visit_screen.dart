import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../models/visit_model.dart";
import "../repositories/visits_repository.dart";

/// Schedule Visit Screen (`screen-schedule-visit`)
/// Matches the CRM Pro master design system and exact visual specification from screenshot:
/// - Top Bar: Back arrow, "Schedule Visit" title, "Save" teal pill button
/// - Associated Lead / Customer dropdown selector
/// - Contact Person field
/// - 2-Column row: Visit Date (with calendar icon) & Visit Time
/// - Visit Type dropdown with teal dot bullet
/// - Purpose / Agenda multiline text area with validation support
/// - Estimated Duration horizontal chip selector (30 min, 1 hr, 1.5 hr, 2 hr)
/// - "Add to Active Route" toggle with subtitle
/// - Full-width "Schedule Visit" action button
class ScheduleVisitScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<VisitModel>? onSaveVisit;

  const ScheduleVisitScreen({
    super.key,
    this.onBack,
    this.onSaveVisit,
  });

  @override
  State<ScheduleVisitScreen> createState() => _ScheduleVisitScreenState();
}

class _ScheduleVisitScreenState extends State<ScheduleVisitScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedCustomer = "Acme Corp";
  final TextEditingController _contactPersonController =
      TextEditingController(text: "John Doe - CTO");
  final TextEditingController _dateController =
      TextEditingController(text: "Aug 30, 2026");
  final TextEditingController _timeController =
      TextEditingController(text: "10:00 AM");
  String _selectedVisitType = "First Meeting";
  final TextEditingController _purposeController = TextEditingController(
    text:
        "Review Enterprise features list, map compliance concerns, and deliver customized pricing proposal.",
  );
  String _selectedDuration = "1 hr";
  bool _addToActiveRoute = true;
  
  bool _isLoading = false;
  final VisitsRepository _repository = VisitsRepository();

  bool _showDateError = false;
  bool _showPurposeError = false;

  final List<String> _customerList = [
    "Acme Corp",
    "TechVista Solutions",
    "DataFlow Inc",
    "Apex Logistics",
    "Nova Pharmaceuticals",
    "Zenith Retail",
  ];

  final Map<String, String> _customerContacts = {
    "Acme Corp": "John Doe - CTO",
    "TechVista Solutions": "Priya Sharma - HR Director",
    "DataFlow Inc": "Karan Malhotra - MD",
    "Apex Logistics": "Vikram Mehta - VP Sales",
    "Nova Pharmaceuticals": "Dr. Rajesh Iyer - Director",
    "Zenith Retail": "Ananya Deshmukh - Procurement Head",
  };

  final List<String> _visitTypes = [
    "First Meeting",
    "Follow-up",
    "Demo",
    "Proposal Review",
    "Contract Closing",
  ];

  final List<String> _durationOptions = [
    "30 min",
    "1 hr",
    "1.5 hr",
    "2 hr",
  ];

  @override
  void dispose() {
    _contactPersonController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 8, 30),
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2027, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F4C4C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
      ];
      setState(() {
        _dateController.text =
            "${months[picked.month - 1]} ${picked.day}, ${picked.year}";
        _showDateError = false;
      });
    }
  }

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F4C4C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? "AM" : "PM";
      setState(() {
        _timeController.text = "$hour:$minute $period";
      });
    }
  }

  void _handleSubmit() async {
    bool hasError = false;
    if (_dateController.text.trim().isEmpty) {
      setState(() => _showDateError = true);
      hasError = true;
    }
    if (_purposeController.text.trim().isEmpty) {
      setState(() => _showPurposeError = true);
      hasError = true;
    }

    if (hasError) return;

    final contactParts = _contactPersonController.text.split("-");
    final contactName = contactParts[0].trim();
    final contactRole =
        contactParts.length > 1 ? contactParts[1].trim() : "Representative";

    final newVisit = VisitModel(
      id: "visit-${DateTime.now().millisecondsSinceEpoch}",
      time: _timeController.text.trim().isEmpty
          ? "10:00 AM"
          : _timeController.text.trim(),
      status: VisitStatus.upcoming,
      meetingType: _selectedVisitType,
      companyName: _selectedCustomer,
      contactName: contactName.isEmpty ? "Contact Person" : contactName,
      contactRole: contactRole,
      locationAddress: "Mumbai Territory",
      notes: _purposeController.text.trim(),
      duration: _selectedDuration,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      await _repository.scheduleVisit(newVisit);
    } catch (e) {
      // Ignore for demo / show error
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    widget.onSaveVisit?.call(newVisit);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text("Visit scheduled with $_selectedCustomer!"),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(newVisit);
    } else {
      Navigator.of(context).pushReplacementNamed("/visits");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back Button (<)
                GestureDetector(
                  onTap: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed("/visits");
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      size: 28,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),

                // Title
                Text(
                  "Schedule Visit",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                    letterSpacing: -0.4,
                  ),
                ),

                // Save Pill Button
                GestureDetector(
                  onTap: _handleSubmit,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F4C4C),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Save",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Associated Lead / Customer
                _buildFieldLabel("Associated Lead / Customer"),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCustomer,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF4B5563),
                        size: 22,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCustomer = val;
                            if (_customerContacts.containsKey(val)) {
                              _contactPersonController.text =
                                  _customerContacts[val]!;
                            }
                          });
                        }
                      },
                      items: _customerList.map((customer) {
                        return DropdownMenuItem<String>(
                          value: customer,
                          child: Text(customer),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 2. Contact Person
                _buildFieldLabel("Contact Person"),
                const SizedBox(height: 6),
                TextField(
                  controller: _contactPersonController,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
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

                const SizedBox(height: 18),

                // 3. Row: Visit Date & Visit Time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visit Date Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel("Visit Date"),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _showDateError
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFFE5E7EB),
                                  width: _showDateError ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _dateController.text.isEmpty
                                        ? "Select Date"
                                        : _dateController.text,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 19,
                                    color: Color(0xFF6B7280),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_showDateError) ...[
                            const SizedBox(height: 4),
                            Text(
                              "Please select a date",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Visit Time Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel("Visit Time"),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                  width: 1.0,
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _timeController.text.isEmpty
                                    ? "Select Time"
                                    : _timeController.text,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 4. Visit Type Dropdown (with teal bullet dot)
                _buildFieldLabel("Visit Type"),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedVisitType,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF4B5563),
                        size: 22,
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedVisitType = val;
                          });
                        }
                      },
                      items: _visitTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F4C4C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                type,
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 5. Purpose / Agenda
                _buildFieldLabel("Purpose / Agenda"),
                const SizedBox(height: 6),
                TextField(
                  controller: _purposeController,
                  maxLines: 4,
                  onChanged: (val) {
                    if (val.trim().isNotEmpty && _showPurposeError) {
                      setState(() => _showPurposeError = false);
                    }
                  },
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF111827),
                    height: 1.45,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _showPurposeError
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE5E7EB),
                        width: _showPurposeError ? 1.5 : 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _showPurposeError
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE5E7EB),
                        width: _showPurposeError ? 1.5 : 1.0,
                      ),
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
                if (_showPurposeError) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Visit purpose is required",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // 6. Estimated Duration
                _buildFieldLabel("Estimated Duration"),
                const SizedBox(height: 8),
                Row(
                  children: _durationOptions.map((duration) {
                    final isSelected = _selectedDuration == duration;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDuration = duration;
                            });
                          },
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0F4C4C)
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0F4C4C)
                                    : const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              duration,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // 7. Add to Active Route
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add to Active Route",
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Auto-optimizes today's map schedule",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _addToActiveRoute,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF0F4C4C),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFE5E7EB),
                      onChanged: (val) {
                        setState(() {
                          _addToActiveRoute = val;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 8. Schedule Visit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4C4C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Schedule Visit",
                          style: GoogleFonts.inter(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
      ),
    );
  }
}

typedef ScreenScheduleVisit = ScheduleVisitScreen;
