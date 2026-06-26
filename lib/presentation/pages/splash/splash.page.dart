import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/controllers/splash/splash.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class SplashPage extends GetView<SplashController> {
  static const routeName = '/splash';

  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/generated/lend_logo_orange.svg',
                width: 156.0,
              ),
              const SizedBox(height: 32.0),
              Obx(
                () =>
                    controller.isLoading
                        ? const LNDSpinner(size: 25.0)
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
