// ignore_for_file: unused_field

import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Setup step model for Onboarding Welcome checklist
class SetupStepItem {
  final String id;
  final String title;
  final IconData icon;
  final String? description;

  const SetupStepItem({
    required this.id,
    required this.title,
    required this.icon,
    this.description,
  });
}

/// Onboarding Screen 1: Onboarding Welcome Screen
/// Pixel-accurate implementation matching the CRM Pro Field Sales design system.
class OnboardingWelcomeScreen extends StatefulWidget {
  final String userName;
  final String userInitials;
  final String companyName;
  final String assignedTerritory;
  final List<SetupStepItem> steps;
  final VoidCallback? onLetsGo;

  const OnboardingWelcomeScreen({
    super.key,
    this.userName = "Arjun",
    this.userInitials = "AM",
    this.companyName = "Acme Industries",
    this.assignedTerritory = "South Mumbai",
    this.steps = const [
      SetupStepItem(
        id: "location",
        title: "Location Access",
        icon: Icons.location_on_outlined,
        description: "Enables client geolocation and route tracking",
      ),
      SetupStepItem(
        id: "camera",
        title: "Camera Access",
        icon: Icons.camera_alt_outlined,
        description: "Enables invoice and visual proof scanning",
      ),
      SetupStepItem(
        id: "microphone",
        title: "Microphone Access",
        icon: Icons.mic_none_outlined,
        description: "Enables audio memos and visit notes",
      ),
      SetupStepItem(
        id: "notifications",
        title: "Notifications",
        icon: Icons.notifications_none_outlined,
        description: "Delivers urgent field visit updates and reminders",
      ),
      SetupStepItem(
        id: "offline_data",
        title: "Offline Data Setup",
        icon: Icons.dns_outlined,
        description: "Syncs territory master data for offline work",
      ),
    ],
    this.onLetsGo,
  });

  @override
  State<OnboardingWelcomeScreen> createState() =>
      _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState extends State<OnboardingWelcomeScreen> {
  final Set<String> _completedStepIds = {};
  final bool _isSyncing = false;

  void _toggleStep(String stepId) {
    setState(() {
      if (_completedStepIds.contains(stepId)) {
        _completedStepIds.remove(stepId);
      } else {
        _completedStepIds.add(stepId);
      }
    });
  }

  void _handleLetsGo() {
    if (widget.onLetsGo != null) {
      widget.onLetsGo!();
    } else {
      // Default navigation to next onboarding screen or dashboard
      Navigator.of(context).pushNamed("/onboarding-step-2");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // 1. Top Avatar Badge: Centered dark teal squircle with white initials ("AM")
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary, // #0F4C4C
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.userInitials,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Greeting Headline: "Hi Arjun!"
              Text(
                "Hi ${widget.userName}!",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // 3. Subtitle / Description
              Text(
                "Let's set up your field kit in under a minute to prepare for ${widget.assignedTerritory} territory operations.",
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 20),

              // 4. Company & Territory Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFF3F4F6,
                  ), // Neutral grey card background
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    // Mint circular icon badge with briefcase
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD1FADF), // Mint circle background
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.business_center_outlined,
                        size: 20,
                        color: Color(0xFF0F766E), // Deep mint/teal
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Company Name & Assigned Territory
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.companyName,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Assigned Territory: ${widget.assignedTerritory}",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. Section Header: "REQUIRED SETUP PROGRESS"
              Text(
                "REQUIRED SETUP PROGRESS",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                  letterSpacing: 0.6,
                ),
              ),

              const SizedBox(height: 8),

              // 6. Checklist Items
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: widget.steps.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = widget.steps[index];
                    final isCompleted = _completedStepIds.contains(item.id);

                    return InkWell(
                      onTap: () => _toggleStep(item.id),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 2.0,
                        ),
                        child: Row(
                          children: [
                            // Left item icon
                            Icon(
                              item.icon,
                              size: 22,
                              color: isCompleted
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 14),

                            // Item title
                            Expanded(
                              child: Text(
                                item.title,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),

                            // Right circular status indicator / radio
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? const Color(0xFF10B981)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isCompleted
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFD1D5DB),
                                  width: 1.8,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 7. Bottom CTA Button: "Let's Go"
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _handleLetsGo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusButton,
                        ),
                      ),
                    ),
                    child: Text(
                      "Let's Go",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
