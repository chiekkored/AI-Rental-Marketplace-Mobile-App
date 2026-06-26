import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/onboarding/onboarding.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingPage extends GetView<OnboardingController> {
  static const routeName = '/onboarding';

  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 18.0),
          child: Column(
            children: [
              const _OnboardingTopBar(),
              const SizedBox(height: 8.0),
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  children: _OnboardingSlideData.slides
                      .map((slide) => _OnboardingSlide(data: slide))
                      .toList(growable: false),
                ),
              ),
              const SizedBox(height: 12.0),
              const _OnboardingFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingTopBar extends GetView<OnboardingController> {
  const _OnboardingTopBar();

  @override
  Widget build(BuildContext context) {
    // final colors = context.lndTheme;
    final isLoading =
        controller.isRequestingLocation || controller.isRequestingNotifications;

    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (controller.currentPage > 0)
            LNDButton.back(
              onPressed: controller.previousPage,
              enabled: !isLoading,
            )
          else
            const SizedBox(width: 40.0, height: 40.0),
          // LNDButton.text(
          //   text: 'Skip',
          //   enabled: true,
          //   color: colors.textMuted,
          //   hasPadding: false,
          //   onPressed: controller.finishOnboarding,
          // ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingSlideData data;

  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (data.showLogo) ...[
          SvgPicture.asset(
            'assets/svg/lend_logo.svg',
            width: 104.0,
            height: 46.0,
          ),
          const SizedBox(height: 18.0),
        ],
        Flexible(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600.0),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Image.asset(data.imageAsset, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: LNDText.bold(
            text: data.title,
            fontSize: 27.0,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.visible,
          ),
        ),
        const SizedBox(height: 12.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: LNDText.regular(
            text: data.subtitle,
            color: colors.textSecondary,
            fontSize: 15.0,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}

class _OnboardingSlideData {
  final String imageAsset;
  final String title;
  final String subtitle;
  final bool showLogo;

  const _OnboardingSlideData({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    this.showLogo = false,
  });

  static const slides = [
    _OnboardingSlideData(
      imageAsset: 'assets/images/onboarding_welcome.png',
      title: 'Rent what you need. Earn from what you own.',
      subtitle:
          'Find nearby items, book dates, chat with owners, and manage rentals from one app.',
      showLogo: true,
    ),
    _OnboardingSlideData(
      imageAsset: 'assets/images/onboarding_location.png',
      title: 'Discover rentals around you',
      subtitle:
          'Use your location to see nearby listings and set accurate pickup areas faster.',
    ),
    _OnboardingSlideData(
      imageAsset: 'assets/images/onboarding_notification.png',
      title: 'Never miss a rental update',
      subtitle:
          'Get notified about booking requests, replies, confirmations, and reminders.',
    ),
    _OnboardingSlideData(
      imageAsset: 'assets/images/onboarding_explore.png',
      title: 'Start exploring verified users',
      subtitle:
          'Browse rentals from people building trust through verification, reviews, and clear booking history.',
    ),
  ];
}

class _OnboardingFooter extends GetView<OnboardingController> {
  const _OnboardingFooter();

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Obx(() {
      final page = controller.currentPage;
      final primaryText = switch (page) {
        0 => 'Get started',
        1 => 'Use my location',
        2 => 'Enable notifications',
        _ => 'Start exploring',
      };
      final secondaryText = switch (page) {
        1 => 'Choose later',
        2 => 'Not now',
        _ => '',
      };
      final isLoading =
          controller.isRequestingLocation ||
          controller.isRequestingNotifications;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: page == index ? 22.0 : 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                decoration: BoxDecoration(
                  color: page == index ? colors.primary : colors.outline,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14.0),
          LNDButton.primary(
            text: primaryText,
            enabled: !isLoading,
            isLoading: isLoading,
            onPressed:
                page == 1
                    ? controller.requestLocation
                    : page == 2
                    ? controller.requestNotifications
                    : controller.nextPage,
          ),
          if (secondaryText.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            LNDButton.text(
              text: secondaryText,
              enabled: !isLoading,
              color: colors.textMuted,
              onPressed: controller.nextPage,
            ),
          ],
        ],
      );
    });
  }
}
