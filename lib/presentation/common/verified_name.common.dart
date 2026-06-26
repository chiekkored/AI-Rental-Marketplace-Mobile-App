import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/enums/eligibility.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

enum LNDVerifiedNameWeight { regular, medium, semibold, bold }

void _showBadgeInfo({required String title, required String description}) {
  LNDShow.bottomSheetInfo<void>([
    LNDText.regular(text: description, overflow: TextOverflow.visible),
  ], title: title);
}

class _BadgeTapTarget extends StatelessWidget {
  const _BadgeTapTarget({
    required this.child,
    required this.title,
    required this.description,
  });

  final Widget child;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showBadgeInfo(title: title, description: description),
      child: child,
    );
  }
}

class LNDVerifiedName extends StatelessWidget {
  const LNDVerifiedName({
    super.key,
    required this.name,
    this.verificationLevel,
    this.fontSize = 14.0,
    this.color,
    this.weight = LNDVerifiedNameWeight.regular,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.textAlign,
    this.badgeSize = 16.0,
    this.spacing = 4.0,
    this.showBusinessBadge = false,
    this.showFoundingOwnerBadge = false,
    this.foundingOwnerBadgeShiny = false,
  });

  final String name;
  final VerificationLevel? verificationLevel;
  final double fontSize;
  final Color? color;
  final LNDVerifiedNameWeight weight;
  final int? maxLines;
  final TextOverflow overflow;
  final MainAxisAlignment mainAxisAlignment;
  final TextAlign? textAlign;
  final double badgeSize;
  final double spacing;
  final bool showBusinessBadge;
  final bool showFoundingOwnerBadge;
  final bool foundingOwnerBadgeShiny;

  @override
  Widget build(BuildContext context) {
    final foundingBadge =
        showFoundingOwnerBadge
            ? LNDFoundingOwnerBadge(
              size: badgeSize,
              shiny: foundingOwnerBadgeShiny,
            )
            : const SizedBox.shrink();
    final badge = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 4.0,
      children: [
        showBusinessBadge
            ? LNDBusinessNameBadge(size: badgeSize)
            : LNDVerificationBadge(
              level: verificationLevel,
              size: badgeSize + 2,
            ),
        foundingBadge,
      ],
    );
    final hasBadge =
        showFoundingOwnerBadge ||
        showBusinessBadge ||
        verificationLevel != null &&
            verificationLevel != VerificationLevel.none;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Flexible(child: _buildText()),
        if (hasBadge) ...[SizedBox(width: spacing), badge],
      ],
    );
  }

  Widget _buildText() {
    switch (weight) {
      case LNDVerifiedNameWeight.regular:
        return LNDText.regular(
          text: name,
          color: color,
          fontSize: fontSize,
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
        );
      case LNDVerifiedNameWeight.medium:
        return LNDText.medium(
          text: name,
          color: color,
          fontSize: fontSize,
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
        );
      case LNDVerifiedNameWeight.semibold:
        return LNDText.semibold(
          text: name,
          color: color,
          fontSize: fontSize,
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
        );
      case LNDVerifiedNameWeight.bold:
        return LNDText.bold(
          text: name,
          color: color,
          fontSize: fontSize,
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
        );
    }
  }
}

class LNDFoundingOwnerBadge extends StatefulWidget {
  const LNDFoundingOwnerBadge({
    super.key,
    this.size = 16.0,
    this.shiny = false,
  });

  static const badgeKey = ValueKey('founding-owner-badge');

  final double size;
  final bool shiny;

  @override
  State<LNDFoundingOwnerBadge> createState() => _LNDFoundingOwnerBadgeState();
}

class _LNDFoundingOwnerBadgeState extends State<LNDFoundingOwnerBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _shineAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant LNDFoundingOwnerBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.shiny != widget.shiny) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    final shouldAnimate =
        widget.shiny &&
        !(MediaQuery.maybeOf(context)?.disableAnimations ?? false);

    if (shouldAnimate) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (!widget.shiny || disableAnimations) {
      return _buildTapTarget(_buildBadge());
    }

    return _buildTapTarget(
      SizedBox.square(
        dimension: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            _buildGlow(),
            AnimatedBuilder(
              animation: _shineAnimation,
              builder: (context, _) {
                return _buildBadge(shinePosition: _shineAnimation.value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTapTarget(Widget child) {
    return _BadgeTapTarget(
      title: 'Founding Owner',
      description:
          'This owner was part of Lend’s early invite program for founding owners..',
      child: child,
    );
  }

  Widget _buildBadge({double? shinePosition}) {
    final primary = context.lndTheme.primary;

    // Important:
    // The animated shine starts fully outside the left side
    // and ends fully outside the right side.
    // That makes the repeat reset visually invisible.
    final shineCenter =
        shinePosition == null ? 0.34 : -2.4 + (shinePosition * 4.8);

    return ShaderMask(
      key: LNDFoundingOwnerBadge.badgeKey,
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(shineCenter - 0.75, -1.0),
          end: Alignment(shineCenter + 0.75, 1.0),
          colors: [
            primary.withValues(alpha: 0.96),
            primary,
            const Color(0xFFFFFFFF),
            primary,
            primary.withValues(alpha: 0.96),
          ],
          stops: const [0.0, 0.42, 0.5, 0.58, 1.0],
        ).createShader(bounds);
      },
      child: FaIcon(
        FontAwesomeIcons.medal,
        color: Colors.white,
        size: widget.size,
      ),
    );
  }

  Widget _buildGlow() {
    final primary = context.lndTheme.primary;
    final glowSize = widget.size * 1.45;

    return SizedBox.square(
      dimension: glowSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.42),
              primary.withValues(alpha: 0.22),
              primary.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.48, 1.0],
          ),
        ),
      ),
    );
  }
}

class LNDBusinessNameBadge extends StatelessWidget {
  const LNDBusinessNameBadge({super.key, this.size = 16.0});

  static const badgeKey = ValueKey('business-name-badge');

  final double size;

  @override
  Widget build(BuildContext context) {
    return _BadgeTapTarget(
      title: 'Business name',
      description:
          'This owner is showing an approved business name on their listings.',
      child: FaIcon(
        FontAwesomeIcons.store,
        key: badgeKey,
        color: context.lndTheme.primary,
        size: size,
      ),
    );
  }
}

class LNDVerificationBadge extends StatelessWidget {
  const LNDVerificationBadge({
    super.key,
    required this.level,
    this.size = 16.0,
  });

  static const basicAsset = 'assets/svg/basic_verification.svg';
  static const fullAsset = 'assets/svg/full_verification.svg';

  final VerificationLevel? level;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = switch (level) {
      VerificationLevel.basic => basicAsset,
      VerificationLevel.full => fullAsset,
      _ => null,
    };

    if (asset == null) return const SizedBox.shrink();

    final (title, description) = switch (level) {
      VerificationLevel.basic => (
        'Basic verified',
        'This user has completed Lend’s basic verification requirements.',
      ),
      VerificationLevel.full => (
        'Fully verified',
        'This user has completed Lend’s full verification requirements for higher-trust marketplace actions.',
      ),
      _ => ('Verification', 'This badge shows a user’s verification level.'),
    };

    return _BadgeTapTarget(
      title: title,
      description: description,
      child: SizedBox.square(
        dimension: size,
        child: SvgPicture.asset(asset, key: ValueKey(asset)),
      ),
    );
  }
}
