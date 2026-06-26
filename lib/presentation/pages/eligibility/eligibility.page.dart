import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/services/get_storage.service.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/verified_name.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/utilities/constants/get_storage.constant.dart';
import 'package:lend/utilities/enums/eligibility.enum.dart';
import 'package:lend/utilities/enums/email_verification_request_outcome.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class EligibilityPage extends StatelessWidget {
  static const routeName = '/eligibility';
  const EligibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final colors = context.lndTheme;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar:
            canPop
                ? AppBar(
                  leading: LNDButton.close(),
                  surfaceTintColor: colors.surface,
                  backgroundColor: colors.surface,
                )
                : null,
        backgroundColor: colors.background,
        body: SafeArea(
          child: Obx(() {
            final profileController = ProfileController.instance;
            final verified = profileController.verified;
            final isNone = verified == VerificationLevel.none;
            final isBasic = verified == VerificationLevel.basic;
            final isPendingFullVerification =
                profileController.hasPendingFullVerification;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
              children: [
                _EligibilityHeader(
                  title: _titleFor(
                    isNone: isNone,
                    isBasic: isBasic,
                    isPendingFullVerification: isPendingFullVerification,
                  ),
                  description: _descriptionFor(
                    isNone: isNone,
                    isBasic: isBasic,
                    isPendingFullVerification: isPendingFullVerification,
                  ),
                  verificationLevel: verified,
                  isPendingFullVerification: isPendingFullVerification,
                ),
                const SizedBox(height: 16.0),
                _VerifiedPerksSection(verificationLevel: verified),
                // const SizedBox(height: 16.0),
                const Center(
                  child: SizedBox(
                    height: 16.0,
                    child: VerticalDivider(thickness: 5.0),
                  ),
                ),
                _FullVerificationPerksSection(
                  verificationLevel: verified,
                  isPendingFullVerification: isPendingFullVerification,
                ),
                const SizedBox(height: 20.0),
                _EligibilityActions(
                  isNone: isNone,
                  isBasic: isBasic,
                  isPendingFullVerification: isPendingFullVerification,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  String _titleFor({
    required bool isNone,
    required bool isBasic,
    required bool isPendingFullVerification,
  }) {
    if (isNone) return 'Verify your email';
    if (isPendingFullVerification) return 'Verification pending';
    if (isBasic) return 'Get fully verified';
    return 'Fully verified';
  }

  String _descriptionFor({
    required bool isNone,
    required bool isBasic,
    required bool isPendingFullVerification,
  }) {
    if (isNone) {
      return 'Start with email verification to unlock renting, chat, saved listings, and trusted booking actions.';
    }
    if (isPendingFullVerification) {
      return 'Your full verification request is under review. You can keep booking listings without security deposits while waiting.';
    }
    if (isBasic) {
      return 'Add phone, address, ID, and face verification to book listings with security deposits, list assets, and receive payouts.';
    }
    return 'Your profile can show the full verification badge, list assets, and receive payouts.';
  }
}

class _EligibilityHeader extends StatelessWidget {
  final String title;
  final String description;
  final VerificationLevel verificationLevel;
  final bool isPendingFullVerification;

  const _EligibilityHeader({
    required this.title,
    required this.description,
    required this.verificationLevel,
    required this.isPendingFullVerification,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              'assets/images/listing.png',
              width: Get.width.clamp(220.0, 320.0),
            ),
          ),
          const SizedBox(height: 16.0),
          _VerificationStatusPill(
            verificationLevel: verificationLevel,
            isPendingFullVerification: isPendingFullVerification,
          ),
          const SizedBox(height: 10.0),
          LNDText.bold(
            text: title,
            fontSize: 24.0,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: 8.0),
          LNDText.regular(
            text: description,
            color: colors.textMuted,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}

class _VerificationStatusPill extends StatelessWidget {
  final VerificationLevel verificationLevel;
  final bool isPendingFullVerification;

  const _VerificationStatusPill({
    required this.verificationLevel,
    required this.isPendingFullVerification,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final label =
        isPendingFullVerification
            ? 'Full verification pending'
            : '${verificationLevel.label} verified';
    final color =
        verificationLevel == VerificationLevel.none
            ? colors.warning
            : isPendingFullVerification
            ? colors.info
            : colors.success;
    final background =
        verificationLevel == VerificationLevel.none
            ? colors.warningSoft
            : isPendingFullVerification
            ? colors.infoSoft
            : colors.successSoft;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (verificationLevel == VerificationLevel.none)
            Icon(Icons.verified_user_outlined, size: 16.0, color: color)
          else
            LNDVerificationBadge(level: verificationLevel, size: 16.0),
          const SizedBox(width: 6.0),
          LNDText.bold(text: label, fontSize: 12.0, color: color),
        ],
      ),
    );
  }
}

class _VerifiedPerksSection extends StatelessWidget {
  final VerificationLevel verificationLevel;

  const _VerifiedPerksSection({required this.verificationLevel});

  @override
  Widget build(BuildContext context) {
    final isVerified = verificationLevel != VerificationLevel.none;
    return _PerksSection(
      title: 'Verified user perks',
      description: 'Available once your email verification is complete.',
      children: [
        _PerkChecklistItem(
          text: 'Book listings from trusted owners',
          isAvailable: isVerified,
        ),
        _PerkChecklistItem(
          text: 'Chat with owners and manage rental activity',
          isAvailable: isVerified,
        ),
      ],
    );
  }
}

class _FullVerificationPerksSection extends StatelessWidget {
  final VerificationLevel verificationLevel;
  final bool isPendingFullVerification;

  const _FullVerificationPerksSection({
    required this.verificationLevel,
    required this.isPendingFullVerification,
  });

  @override
  Widget build(BuildContext context) {
    final hasFullAccess = verificationLevel == VerificationLevel.full;
    final description =
        isPendingFullVerification
            ? 'Your request is being reviewed. These unlock after approval.'
            : 'Add full verification to unlock owner tools.';
    return _PerksSection(
      title: 'Full verification perks',
      description: description,
      children: [
        _PerkChecklistItem(
          text: 'Create and publish listings',
          isAvailable: hasFullAccess,
        ),
        _PerkChecklistItem(
          text: 'Receive owner payouts',
          isAvailable: hasFullAccess,
        ),
        _PerkChecklistItem(
          text: 'Book listings with security deposits',
          isAvailable: hasFullAccess,
        ),
        _PerkChecklistItem(
          text: 'Set a security deposit return destination',
          isAvailable: hasFullAccess,
        ),
        _PerkChecklistItem(
          text: 'Show a full verification badge on your profile',
          isAvailable: hasFullAccess,
        ),
      ],
    );
  }
}

class _PerksSection extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> children;

  const _PerksSection({
    required this.title,
    required this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LNDText.bold(text: title, fontSize: 16.0),
          const SizedBox(height: 4.0),
          LNDText.regular(
            text: description,
            color: colors.textMuted,
            fontSize: 13.0,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: 14.0),
          ...children,
        ],
      ),
    );
  }
}

class _PerkChecklistItem extends StatelessWidget {
  final String text;
  final bool isAvailable;

  const _PerkChecklistItem({required this.text, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final iconColor = isAvailable ? colors.success : colors.disabled;
    final textColor = isAvailable ? colors.textPrimary : colors.textMuted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isAvailable
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: iconColor,
            size: 20.0,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: LNDText.regular(
              text: text,
              color: textColor,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

class _EligibilityActions extends StatefulWidget {
  final bool isNone;
  final bool isBasic;
  final bool isPendingFullVerification;

  const _EligibilityActions({
    required this.isNone,
    required this.isBasic,
    required this.isPendingFullVerification,
  });

  @override
  State<_EligibilityActions> createState() => _EligibilityActionsState();
}

class _EligibilityActionsState extends State<_EligibilityActions> {
  static const _resendCooldown = Duration(seconds: 120);
  static const _verificationCheckCooldown = Duration(seconds: 10);

  Timer? _resendTimer;
  Timer? _verificationCheckTimer;
  bool _isResendingEmail = false;
  bool _isCheckingVerification = false;
  DateTime? _resendAvailableAt;
  DateTime? _verificationCheckAvailableAt;

  Duration get _resendRemaining => _remainingUntil(_resendAvailableAt);
  Duration get _verificationCheckRemaining =>
      _remainingUntil(_verificationCheckAvailableAt);
  bool get _isResendCoolingDown => _resendRemaining > Duration.zero;
  bool get _isVerificationCheckCoolingDown =>
      _verificationCheckRemaining > Duration.zero;

  @override
  void initState() {
    super.initState();
    _restoreResendCooldown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _verificationCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNone) {
      final resendEnabled = !_isResendingEmail && !_isResendCoolingDown;
      final checkEnabled =
          !_isCheckingVerification && !_isVerificationCheckCoolingDown;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LNDButton.primary(
            text: _resendButtonText,
            enabled: resendEnabled,
            isLoading: _isResendingEmail,
            borderRadius: 12.0,
            onPressed: resendEnabled ? _resendEmailVerification : null,
          ),
          const SizedBox(height: 10.0),
          LNDButton.text(
            text: 'I verified my email',
            enabled: checkEnabled,
            isLoading: _isCheckingVerification,
            onPressed: checkEnabled ? _checkEmailVerification : null,
          ),
        ],
      );
    }

    if (widget.isBasic && !widget.isPendingFullVerification) {
      return LNDButton.primary(
        text: 'Apply for full verification',
        enabled: true,
        borderRadius: 12.0,
        onPressed: LNDNavigate.toFullVerificationPage,
      );
    }

    return const SizedBox.shrink();
  }

  String get _resendButtonText {
    final remaining = _resendRemaining;
    if (remaining <= Duration.zero) return 'Resend email';
    final totalSeconds = remaining.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _resendEmailVerification() async {
    if (_isResendingEmail || _isResendCoolingDown) return;

    _startResendCooldown();
    setState(() => _isResendingEmail = true);

    try {
      final outcome = await AuthController.instance.resendEmailVerification();
      if (!mounted) return;

      switch (outcome) {
        case EmailVerificationRequestOutcome.autoVerified:
        case EmailVerificationRequestOutcome.alreadyVerified:
          LNDSnackbar.showSuccess('Your email has been verified.');
        case EmailVerificationRequestOutcome.emailSent:
          LNDSnackbar.showInfo('Sent a verification link to your email.');
        case EmailVerificationRequestOutcome.deliveryUnavailable:
          LNDSnackbar.showWarning(
            'Email verification is temporarily unavailable.',
          );
      }
    } finally {
      if (mounted) setState(() => _isResendingEmail = false);
    }
  }

  Future<void> _checkEmailVerification() async {
    if (_isCheckingVerification || _isVerificationCheckCoolingDown) return;

    setState(() => _isCheckingVerification = true);

    try {
      await ProfileController.instance.syncEmailVerification();
      if (!mounted) return;

      final isVerified =
          ProfileController.instance.verified != VerificationLevel.none ||
          AuthController.instance.currentUser?.emailVerified == true;
      if (isVerified) {
        LNDSnackbar.showSuccess('Your email has been verified.');
      } else {
        LNDSnackbar.showInfo('We could not confirm your verification yet.');
        _startVerificationCheckCooldown();
      }
    } finally {
      if (mounted) setState(() => _isCheckingVerification = false);
    }
  }

  void _restoreResendCooldown() {
    final uid = AuthController.instance.uid;
    if (uid == null || uid.isEmpty) return;

    final availableAtMs = LNDStorageService.read<int>(
      LNDStorageConstants.emailVerificationResendAvailableAtKey(uid),
    );
    if (availableAtMs == null) return;

    final availableAt = DateTime.fromMillisecondsSinceEpoch(availableAtMs);
    if (_remainingUntil(availableAt) <= Duration.zero) {
      unawaited(
        LNDStorageService.remove(
          LNDStorageConstants.emailVerificationResendAvailableAtKey(uid),
        ),
      );
      return;
    }

    _resendAvailableAt = availableAt;
    _startResendTimer();
  }

  void _startResendCooldown() {
    final uid = AuthController.instance.uid;
    final availableAt = DateTime.now().add(_resendCooldown);
    _resendAvailableAt = availableAt;

    if (uid != null && uid.isNotEmpty) {
      unawaited(
        LNDStorageService.write(
          LNDStorageConstants.emailVerificationResendAvailableAtKey(uid),
          availableAt.millisecondsSinceEpoch,
        ),
      );
    }

    _startResendTimer();
  }

  void _startVerificationCheckCooldown() {
    _verificationCheckAvailableAt = DateTime.now().add(
      _verificationCheckCooldown,
    );
    _verificationCheckTimer?.cancel();
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_isVerificationCheckCoolingDown) {
        _verificationCheckTimer?.cancel();
        _verificationCheckTimer = null;
      }
      setState(() {});
    });
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_isResendCoolingDown) {
        _resendTimer?.cancel();
        _resendTimer = null;
        _clearResendCooldown();
      }
      setState(() {});
    });
    setState(() {});
  }

  void _clearResendCooldown() {
    final uid = AuthController.instance.uid;
    _resendAvailableAt = null;
    if (uid == null || uid.isEmpty) return;
    unawaited(
      LNDStorageService.remove(
        LNDStorageConstants.emailVerificationResendAvailableAtKey(uid),
      ),
    );
  }

  Duration _remainingUntil(DateTime? availableAt) {
    if (availableAt == null) return Duration.zero;
    final remaining = availableAt.difference(DateTime.now());
    if (remaining <= Duration.zero) return Duration.zero;
    return Duration(seconds: remaining.inSeconds + 1);
  }
}
