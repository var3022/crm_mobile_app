import "dart:async";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_dimensions.dart";
import "../../../core/theme/app_spacing.dart";

/// Screen 6 of Onboarding: Prepare for Offline Data Setup
/// Follows CRM Pro Flutter/Dart design system and architecture.
class OnboardingOfflineSetupScreen extends StatefulWidget {
  final VoidCallback? onDownloadComplete;
  final VoidCallback? onSkip;

  const OnboardingOfflineSetupScreen({
    super.key,
    this.onDownloadComplete,
    this.onSkip,
  });

  @override
  State<OnboardingOfflineSetupScreen> createState() =>
      _OnboardingOfflineSetupScreenState();
}

class _OnboardingOfflineSetupScreenState
    extends State<OnboardingOfflineSetupScreen> {
  bool _isDownloading = false;
  bool _isCompleted = false;
  double _progress = 0.60; // Initial 60% as seen in reference design
  int _downloadedCount = 72; // 72 of 120 leads
  final int _totalCount = 120;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startDownload() {
    if (_isDownloading || _isCompleted) return;

    setState(() {
      _isDownloading = true;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_downloadedCount < _totalCount) {
          _downloadedCount += 2;
          if (_downloadedCount > _totalCount) {
            _downloadedCount = _totalCount;
          }
          _progress = _downloadedCount / _totalCount;
        } else {
          timer.cancel();
          _isDownloading = false;
          _isCompleted = true;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Offline cache ready! South Mumbai territory synced.",
              ),
              backgroundColor: AppColors.primary,
              duration: Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) {
              if (widget.onDownloadComplete != null) {
                widget.onDownloadComplete!();
              } else {
                Navigator.of(
                  context,
                ).pushReplacementNamed("/onboarding-complete");
              }
            }
          });
        }
      });
    });
  }

  void _handleSkip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.of(context).pushReplacementNamed("/onboarding-complete");
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_progress * 100).toInt();

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
              const SizedBox(height: 12),

              // 1. Top Progress Bar (Step 6 of Onboarding: 100% full dark teal line)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 4.5,
                  width: double.infinity,
                  color: const Color(0xFFE5E7EB),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1.0, // 100% full
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary, // #0F4C4C
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Hero Graphic Card: Soft mint card with cloud download vector illustration
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF9), // Soft mint tint
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(120, 110),
                  painter: _CloudDownloadIllustrationPainter(),
                ),
              ),

              const SizedBox(height: 28),

              // 3. Title: "Prepare for Offline"
              Text(
                "Prepare for Offline",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 10),

              // 4. Subtitle / Purpose Explanation
              Text(
                "Download your leads and customer data so you can work without internet.",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 22),

              // 5. Territory Payload Information Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB), // Soft subtle background
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFF3F4F6),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top header: Territory name + Payload size
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "SOUTH MUMBAI SYNC PAYLOAD",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B7280),
                            letterSpacing: 0.4,
                          ),
                        ),
                        Text(
                          "~45 MB",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Payload bullet items
                    _PayloadBullet(text: "120 assigned leads"),
                    const SizedBox(height: 5),
                    _PayloadBullet(text: "85 customers in territory"),
                    const SizedBox(height: 5),
                    _PayloadBullet(text: "7 days offline visit logs"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 6. Download Progress Indicator Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isCompleted
                            ? "Download complete"
                            : _isDownloading
                            ? "Downloading leads..."
                            : "Downloading leads...",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "$_downloadedCount / $_totalCount ($percent%)",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Linear Progress Bar Track & Fill
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 5.5,
                      width: double.infinity,
                      color: const Color(0xFFE5E7EB),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progress,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 60),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 7. Bottom Action Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Column(
                  children: [
                    // Primary CTA: "Download Now"
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _startDownload,
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
                        child: _isDownloading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Downloading...",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                _isCompleted
                                    ? "Sync Completed"
                                    : "Download Now",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Secondary Action: "Skip — I'll sync later"
                    TextButton(
                      onPressed: _handleSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                      child: Text(
                        "Skip — I'll sync later",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper bullet point widget for payload items
class _PayloadBullet extends StatelessWidget {
  final String text;

  const _PayloadBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4.5,
          height: 4.5,
          margin: const EdgeInsets.only(right: 8, left: 2),
          decoration: const BoxDecoration(
            color: Color(0xFF374151),
            shape: BoxShape.circle,
          ),
        ),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1F2937),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the minimalist cloud download vector illustration matching the reference image
class _CloudDownloadIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const tealColor = Color(0xFF0F4C4C);

    final strokePaint = Paint()
      ..color = tealColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 100.0;
    final scaleY = size.height / 100.0;

    // 1. Cloud Outline (Left lobe, apex dome, right lobe, bottom curves)
    final cloudPath = Path();

    // Start near bottom left opening/curve
    cloudPath.moveTo(42.0 * scaleX, 66.0 * scaleY);

    // Left lower flank and lobe
    cloudPath.cubicTo(
      36.0 * scaleX,
      66.0 * scaleY,
      27.0 * scaleX,
      61.0 * scaleY,
      26.0 * scaleX,
      51.0 * scaleY,
    );

    // Left upper curve
    cloudPath.cubicTo(
      25.0 * scaleX,
      41.0 * scaleY,
      33.0 * scaleX,
      33.0 * scaleY,
      43.0 * scaleX,
      33.0 * scaleY,
    );

    // Center apex top dome
    cloudPath.cubicTo(
      47.0 * scaleX,
      22.0 * scaleY,
      61.0 * scaleX,
      22.0 * scaleY,
      67.0 * scaleX,
      32.0 * scaleY,
    );

    // Right upper curve and lobe
    cloudPath.cubicTo(
      77.0 * scaleX,
      33.0 * scaleY,
      83.0 * scaleX,
      42.0 * scaleY,
      82.0 * scaleX,
      51.0 * scaleY,
    );

    // Right lower flank to bottom right opening
    cloudPath.cubicTo(
      81.0 * scaleX,
      61.0 * scaleY,
      72.0 * scaleX,
      66.0 * scaleY,
      58.0 * scaleX,
      66.0 * scaleY,
    );

    canvas.drawPath(cloudPath, strokePaint);

    // 2. Downward Arrow: vertical shaft + downward arrowhead V
    final arrowPath = Path();

    // Vertical shaft
    arrowPath.moveTo(50.0 * scaleX, 46.0 * scaleY);
    arrowPath.lineTo(50.0 * scaleX, 72.0 * scaleY);

    // Left wing of arrowhead
    arrowPath.moveTo(43.0 * scaleX, 64.0 * scaleY);
    arrowPath.lineTo(50.0 * scaleX, 72.0 * scaleY);

    // Right wing of arrowhead
    arrowPath.lineTo(57.0 * scaleX, 64.0 * scaleY);

    canvas.drawPath(arrowPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
