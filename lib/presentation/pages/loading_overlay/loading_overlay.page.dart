import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/loading/loading.controller.dart';

class LoadingOverlay extends GetWidget<LoadingController> {
  final Widget child;
  const LoadingOverlay({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        GestureDetector(
          onTap: kDebugMode ? controller.hide : null,
          child: Obx(() {
            if (!controller.isLoading.value) return const SizedBox.shrink();
            final text = controller.text.value?.trim();
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LNDSpinner(color: Colors.white),
                            if (text != null && text.isNotEmpty) ...[
                              const SizedBox(height: 14.0),
                              Material(
                                type: MaterialType.transparency,
                                child: LNDText.medium(
                                  text: text,
                                  color: Colors.white,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
