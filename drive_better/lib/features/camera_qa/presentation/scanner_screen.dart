import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'application/scanner_controller.dart';

// ---------------------------------------------------------------------------
// Scanner Screen
// ---------------------------------------------------------------------------

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _cameraPermissionDenied = false;
  bool _cameraInitialized = false;
  bool _torchOn = false;

  bool _unlocked = false;
  bool _checkingUnlock = true;

  // Scanning line animation
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  // Corner bracket pulse
  late AnimationController _cornerPulseController;

  @override
  void initState() {
    super.initState();
    _checkUnlockStatus();
  }

  Future<void> _checkUnlockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isUnlocked = prefs.getBool('developer_unlocked') ?? false;
    if (isUnlocked) {
      if (!mounted) return;
      setState(() {
        _unlocked = true;
        _checkingUnlock = false;
      });
      _initScannerAnimationsAndCamera();
    } else {
      if (!mounted) return;
      setState(() {
        _unlocked = false;
        _checkingUnlock = false;
      });
    }
  }

  void _initScannerAnimationsAndCamera() {
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanLineAnimation = CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    );

    _cornerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _cameraPermissionDenied = true);
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraPermissionDenied = true);
        return;
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (!mounted) return;
      setState(() {
        _cameraController = controller;
        _cameraInitialized = true;
      });

      // Start scanning
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final size = MediaQuery.of(context).size;
          ref
              .read(scannerControllerProvider.notifier)
              .startScanning(controller, size);
        }
      });
    } catch (e) {
      setState(() => _cameraPermissionDenied = true);
    }
  }

  Future<void> _toggleTorch() async {
    if (_cameraController == null || !_cameraInitialized) return;
    try {
      _torchOn = !_torchOn;
      await _cameraController!.setFlashMode(
        _torchOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    if (_unlocked) {
      _scanLineController.dispose();
      _cornerPulseController.dispose();
      _cameraController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingUnlock) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!_unlocked) {
      return _DeveloperLockView(
        onUnlockSuccess: () {
          setState(() {
            _unlocked = true;
          });
          _initScannerAnimationsAndCamera();
        },
      );
    }

    final scanState = ref.watch(scannerControllerProvider);
    final hasMatch = scanState.matchedAnswer != null;

    // When a match is found, stop the scan line animation
    if (hasMatch) {
      _scanLineController.stop();
    } else if (!_scanLineController.isAnimating) {
      _scanLineController.repeat(reverse: true);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Camera preview ──────────────────────────────────────────────
            if (_cameraInitialized && _cameraController != null)
              _CameraPreviewWidget(controller: _cameraController!)
            else if (_cameraPermissionDenied)
              _PermissionDeniedView(onRetry: _initCamera)
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // ── Dark vignette overlay ────────────────────────────────────────
            _ViewfinderOverlay(
              scanLineAnimation: _scanLineAnimation,
              cornerPulse: _cornerPulseController,
              hasMatch: hasMatch,
            ),

            // ── Top bar ─────────────────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TopBarButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    Text(
                      AppLocalizations.of(context)!.scannerTitle,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    _TopBarButton(
                      icon: _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      onTap: _toggleTorch,
                      color: _torchOn ? AppColors.accent : Colors.white,
                    ),
                  ],
                ),
              ),
            ),

            // ── Status chip ─────────────────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 0,
              right: 0,
              child: Center(
                child: _StatusChip(status: scanState.status),
              ),
            ),

            // ── Shutter Button (Manual Capture) ──────────────────────────────
            if (!hasMatch && _cameraInitialized && _cameraController != null)
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: Center(
                  child: _ShutterButton(
                    isLoading: scanState.status == ScanStatus.readingText ||
                        scanState.status == ScanStatus.aiLookup,
                    onTap: () {
                      final size = MediaQuery.of(context).size;
                      ref
                          .read(scannerControllerProvider.notifier)
                          .scanManual(_cameraController!, size);
                    },
                  ),
                ),
              ),

            // ── Answer panel ────────────────────────────────────────────────
            if (hasMatch)
              _AnswerPanel(
                question: scanState.matchedAnswer!,
                confidence: scanState.matchConfidence,
                onDismiss: () {
                  ref.read(scannerControllerProvider.notifier).dismissMatch();
                  if (_cameraController != null) {
                    final size = MediaQuery.of(context).size;
                    ref
                        .read(scannerControllerProvider.notifier)
                        .startScanning(_cameraController!, size);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Camera preview — fills the screen maintaining aspect ratio
// ---------------------------------------------------------------------------

class _CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  const _CameraPreviewWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize?.height ?? constraints.maxWidth,
            height: controller.value.previewSize?.width ?? constraints.maxHeight,
            child: CameraPreview(controller),
          ),
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Viewfinder overlay: semi-dark surround + rounded rect + corners + scan line
// ---------------------------------------------------------------------------

class _ViewfinderOverlay extends StatelessWidget {
  final Animation<double> scanLineAnimation;
  final AnimationController cornerPulse;
  final bool hasMatch;

  const _ViewfinderOverlay({
    required this.scanLineAnimation,
    required this.cornerPulse,
    required this.hasMatch,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 16.0;

    return LayoutBuilder(builder: (context, constraints) {
      final frameW = constraints.maxWidth * 0.88;
      final frameH = constraints.maxHeight * 0.65;
      final cx = constraints.maxWidth / 2;
      final cy = constraints.maxHeight / 2 - 40;
      final left = cx - frameW / 2;
      final top = cy - frameH / 2;

      return Stack(
        fit: StackFit.expand,
        children: [
          // Dark surround with cutout
          CustomPaint(
            painter: _CutoutPainter(
              frameRect: Rect.fromLTWH(left, top, frameW, frameH),
              radius: radius,
            ),
          ),

          // Corner brackets
          AnimatedBuilder(
            animation: cornerPulse,
            builder: (context, _) {
              final opacity = hasMatch
                  ? 1.0
                  : 0.6 + 0.4 * cornerPulse.value;
              final color = hasMatch ? AppColors.success : Colors.white;
              return CustomPaint(
                painter: _CornerBracketPainter(
                  frameRect: Rect.fromLTWH(left, top, frameW, frameH),
                  radius: radius,
                  color: color.withValues(alpha: opacity),
                  bracketSize: 24,
                  strokeWidth: 3,
                ),
              );
            },
          ),

          // Animated scan line (only while scanning)
          if (!hasMatch)
            AnimatedBuilder(
              animation: scanLineAnimation,
              builder: (context, _) {
                final lineY = top + 4 + (frameH - 8) * scanLineAnimation.value;
                return Positioned(
                  left: left + 12,
                  top: lineY,
                  child: Container(
                    width: frameW - 24,
                    height: 2.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.accent,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Hint label below frame
          Positioned(
            left: 0,
            right: 0,
            top: top + frameH + 20,
            child: Builder(builder: (context) {
              final l = AppLocalizations.of(context)!;
              return Text(
                hasMatch ? l.matchFound : l.scannerHint,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
          ),
        ],
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Custom painters
// ---------------------------------------------------------------------------

class _CutoutPainter extends CustomPainter {
  final Rect frameRect;
  final double radius;
  _CutoutPainter({required this.frameRect, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.62);
    final fullPath = Path()..addRect(Offset.zero & size);
    final cutout = Path()
      ..addRRect(RRect.fromRectAndRadius(frameRect, Radius.circular(radius)));
    final path = Path.combine(PathOperation.difference, fullPath, cutout);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CutoutPainter old) =>
      old.frameRect != frameRect || old.radius != radius;
}

class _CornerBracketPainter extends CustomPainter {
  final Rect frameRect;
  final double radius;
  final Color color;
  final double bracketSize;
  final double strokeWidth;

  _CornerBracketPainter({
    required this.frameRect,
    required this.radius,
    required this.color,
    required this.bracketSize,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final l = frameRect.left;
    final t = frameRect.top;
    final r = frameRect.right;
    final b = frameRect.bottom;
    final s = bracketSize;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(l, t + s)
        ..lineTo(l, t + radius)
        ..arcToPoint(Offset(l + radius, t), radius: Radius.circular(radius))
        ..lineTo(l + s, t),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(r - s, t)
        ..lineTo(r - radius, t)
        ..arcToPoint(Offset(r, t + radius), radius: Radius.circular(radius))
        ..lineTo(r, t + s),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(l, b - s)
        ..lineTo(l, b - radius)
        ..arcToPoint(Offset(l + radius, b),
            radius: Radius.circular(radius), clockwise: false)
        ..lineTo(l + s, b),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(r - s, b)
        ..lineTo(r - radius, b)
        ..arcToPoint(Offset(r, b - radius),
            radius: Radius.circular(radius), clockwise: false)
        ..lineTo(r, b - s),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CornerBracketPainter old) =>
      old.color != color || old.frameRect != frameRect;
}

// ---------------------------------------------------------------------------
// Status chip
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  final ScanStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final (label, icon, color) = switch (status) {
      ScanStatus.scanning => (l.scanning, Icons.radar_rounded, Colors.white70),
      ScanStatus.readingText =>
        (l.readingText, Icons.text_fields_rounded, AppColors.accent),
      ScanStatus.aiLookup =>
        ('Asking AI...', Icons.auto_awesome_rounded, AppColors.accent),
      ScanStatus.matchFound =>
        (l.matchFound, Icons.check_circle_rounded, AppColors.success),
      ScanStatus.noMatch =>
        ('No match found', Icons.search_off_rounded, Colors.white54),
      ScanStatus.idle => (l.scanning, Icons.crop_free_rounded, Colors.white54),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate(key: ValueKey(status)).fadeIn(duration: 200.ms);
  }
}

// ---------------------------------------------------------------------------
// Answer panel
// ---------------------------------------------------------------------------

class _AnswerPanel extends StatelessWidget {
  final ScannerAnswer question;
  final double confidence;
  final VoidCallback onDismiss;

  const _AnswerPanel({
    required this.question,
    required this.confidence,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).round();
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l.questionDetected,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Confidence chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded,
                              color: AppColors.success, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '$pct% match',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Question text
                Text(
                  question.questionText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 14),

                // Correct answer chip
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.correctAnswer,
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              question.correctAnswer,
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.success,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Explanation
                Text(
                  question.explanation,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    height: 1.55,
                  ),
                ),

                const SizedBox(height: 14),

                // Source badge + dismiss row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.menu_book_rounded,
                              color: AppColors.accent, size: 12),
                          const SizedBox(width: 5),
                          Text(
                            question.fromAI ? 'AI Answer' : l.fromQuestionBank,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.accentDeep,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    FilledButton.tonal(
                      onPressed: onDismiss,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.outlineVariant,
                        foregroundColor: theme.colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(l.dismiss),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
          .animate()
          .slideY(begin: 1, end: 0, duration: 380.ms, curve: Curves.easeOutCubic)
          .fadeIn(duration: 280.ms),
    );
  }
}

// ---------------------------------------------------------------------------
// Permission denied view
// ---------------------------------------------------------------------------

class _PermissionDeniedView extends StatelessWidget {
  final VoidCallback onRetry;
  const _PermissionDeniedView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_outlined,
                color: Colors.white54, size: 64),
            const SizedBox(height: 20),
            Text(
              'Camera access required',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please allow camera access in your device settings to use the scanner.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white60,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                textStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar icon button
// ---------------------------------------------------------------------------

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _TopBarButton({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shutter button for manual capture
// ---------------------------------------------------------------------------

class _ShutterButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _ShutterButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4.5),
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(5),
        child: AnimatedScale(
          scale: isLoading ? 0.82 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLoading
                  ? AppColors.accent.withValues(alpha: 0.55)
                  : Colors.white,
            ),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.8,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Developer Lock View for Scan Q&A (Under Development)
// ---------------------------------------------------------------------------

class _DeveloperLockView extends StatefulWidget {
  final VoidCallback onUnlockSuccess;

  const _DeveloperLockView({required this.onUnlockSuccess});

  @override
  State<_DeveloperLockView> createState() => _DeveloperLockViewState();
}

class _DeveloperLockViewState extends State<_DeveloperLockView> {
  final List<int> _pin = [];
  bool _hasError = false;
  static const String _correctCode = '51214';

  void _onKeyPress(int number) {
    if (_pin.length >= 5) return;
    setState(() {
      _hasError = false;
      _pin.add(number);
    });

    if (_pin.length == 5) {
      _checkCode();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _hasError = false;
      _pin.removeLast();
    });
  }

  Future<void> _checkCode() async {
    final entered = _pin.join();
    if (entered == _correctCode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('developer_unlocked', true);
      widget.onUnlockSuccess();
    } else {
      setState(() {
        _hasError = true;
      });
      // Clear pins on error after delay
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _pin.clear();
            _hasError = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextHigh : AppColors.lightTextHigh;
    final subtextColor = isDark ? AppColors.darkTextMed : AppColors.lightTextMed;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: textColor),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Duolingo-like lock icon representation
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _hasError ? Icons.lock_open_rounded : Icons.lock_rounded,
                            size: 48,
                            color: _hasError ? AppColors.error : AppColors.accent,
                          ),
                        ),
                      ).animate(target: _hasError ? 1 : 0)
                       .shake(duration: 500.ms, hz: 6, curve: Curves.easeInOut),

                      const SizedBox(height: 24),
                      Text(
                        'Under Development 🛠️',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'The Scan Q&A feature is locked. Enter the developer code to unlock.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: subtextColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // PIN slots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final isFilled = index < _pin.length;
                          final digit = isFilled ? _pin[index].toString() : '';
                          
                          Color slotBorderColor;
                          if (_hasError) {
                            slotBorderColor = AppColors.error;
                          } else if (index == _pin.length) {
                            slotBorderColor = AppColors.primary;
                          } else {
                            slotBorderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
                          }

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 46,
                            height: 56,
                            decoration: BoxDecoration(
                              color: cardColor,
                              border: Border.all(
                                color: slotBorderColor,
                                width: index == _pin.length ? 2.5 : 1.5,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                if (index == _pin.length)
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                digit,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: _hasError ? AppColors.error : textColor,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 40),

                      // Custom NumPad (Duolingo Style Buttons)
                      _buildNumPad(isDark),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumPad(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildNumButton(1, isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildNumButton(2, isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildNumButton(3, isDark)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildNumButton(4, isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildNumButton(5, isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildNumButton(6, isDark)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildNumButton(7, isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildNumButton(8, isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildNumButton(9, isDark)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: SizedBox.shrink()),
            const SizedBox(width: 16),
            Expanded(child: _buildNumButton(0, isDark)),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.backspace_rounded,
                onTap: _onDelete,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumButton(int digit, bool isDark) {
    final shadowColor = isDark ? Colors.black38 : Colors.grey.shade300;
    final buttonColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextHigh : AppColors.lightTextHigh;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => _onKeyPress(digit),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(0, 3),
                blurRadius: 0,
              )
            ],
          ),
          child: Center(
            child: Text(
              digit.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final shadowColor = isDark ? Colors.black38 : Colors.grey.shade300;
    final buttonColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final iconColor = isDark ? AppColors.darkTextHigh : AppColors.lightTextHigh;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(0, 3),
                blurRadius: 0,
              )
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

