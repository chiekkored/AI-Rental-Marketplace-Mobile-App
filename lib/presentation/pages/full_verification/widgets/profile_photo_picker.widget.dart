import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/full_verification/full_verification.controller.dart';
import 'package:lend/utilities/enums/image_type.enum.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class ProfilePhotoPicker extends GetWidget<FullVerificationController> {
  const ProfilePhotoPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Obx(() {
      final photoUrl = controller.profilePhotoUrl.trim();
      final hasPhoto = photoUrl.isNotEmpty;

      return Semantics(
        button: true,
        label: 'Profile photo',
        child: GestureDetector(
          onTap: controller.pickProfilePhoto,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DottedBorder(
                color: colors.outline,
                borderType: BorderType.Circle,
                dashPattern: const [7, 6],
                strokeWidth: 1.5,
                child: SizedBox.square(
                  dimension: 132.0,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasPhoto)
                          LNDImage.circle(
                            imageUrl: photoUrl,
                            size: 120.0,
                            imageType: ImageType.user,
                          )
                        else
                          DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.surfaceMuted,
                            ),
                            child: Icon(
                              Icons.person_add_alt_1_rounded,
                              color: colors.textMuted,
                              size: 36.0,
                            ),
                          ),
                        if (controller.isUploadingProfilePhoto)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.surface.withValues(alpha: 0.72),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: colors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              LNDText.medium(
                text: 'Profile photo',
                color: colors.textMuted,
                textParts: [LNDText.medium(text: '*', color: colors.danger)],
              ),
            ],
          ),
        ),
      );
    });
  }
}
