import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/booking_instructions/booking_instructions.controller.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class BookingInstructionsPage extends GetView<BookingInstructionsController> {
  static const routeName = '/booking-instructions';

  const BookingInstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.surface,
          surfaceTintColor: colors.surface,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 420.0),
                        padding: const EdgeInsets.fromLTRB(
                          20.0,
                          24.0,
                          20.0,
                          22.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 22.0,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.06),
                              blurRadius: 30.0,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            LNDImage.circle(
                              imageUrl: controller.ownerPhotoUrl,
                              size: 72.0,
                            ),
                            const SizedBox(height: 16.0),
                            LNDText.semibold(
                              text: 'From the owner',
                              fontSize: 18.0,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12.0),
                            LNDText.regular(
                              text: controller.instructions,
                              color: colors.textSecondary,
                              overflow: TextOverflow.visible,
                              isSelectable: true,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420.0),
                        child: LNDButton.primary(
                          text: 'Confirm',
                          enabled: true,
                          onPressed: controller.confirm,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
