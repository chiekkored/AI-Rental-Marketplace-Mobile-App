import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/create_listing/create_listing.controller.dart';
import 'package:lend/presentation/pages/create_listing/widgets/create_listing_widgets.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class PhotosStep extends GetView<CreateListingController> {
  const PhotosStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Obx(
      () => CreateListingStepScaffold(
        stepIndex: controller.photosStepIndex,
        title: 'Showcase your item',
        description:
            'High-quality photos increase trust and booking rates. Upload well-lit, clear images of your asset.',
        secondaryText: 'Back',
        secondaryAction:
            () => controller.goToStep(controller.locationStepIndex),
        primaryText: 'Continue',
        primaryAction: controller.continueFromPhotos,
        primaryEnabled: controller.canContinuePhotos.value,
        primaryLoading: controller.isUploadingPhotos.value,
        child: Form(
          key: controller.photosFormKey,
          child: Column(
            children: [
              CreateListingSection(
                title: 'Banner Photos',
                required: true,
                description:
                    'These photos appear in the asset page banner carousel. The first photo is the cover image.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LNDText.medium(
                      text:
                          '${controller.bannerPhotoCount} / ${CreateListingController.maxBannerPhotos} banner photos uploaded',
                      color: colors.textMuted,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 10),
                    if (controller.bannerPhotoCount == 0)
                      CreateListingUploadBox(
                        text: 'Click to upload banner photos',
                        subtitle:
                            'JPG, PNG up to ${CreateListingController.maxBannerPhotos} photos',
                        photo: controller.primaryPhoto.value,
                        hasError: controller.showPrimaryPhotoError.value,
                        onTap: controller.pickPrimaryPhoto,
                        actionTrigger: _photoSourceMenu(
                          child: const SizedBox.expand(),
                          onPick: controller.pickBannerPhotos,
                        ),
                        onRemove: controller.removePrimaryPhoto,
                      )
                    else
                      CreateListingPhotoGrid(
                        leadingPhoto: controller.primaryPhoto.value,
                        photos: controller.additionalPhotos,
                        maxCount: CreateListingController.maxBannerPhotos,
                        onAdd: controller.pickPrimaryPhoto,
                        addTrigger: _photoSourceMenu(
                          child: DottedBorder(
                            color: colors.outline,
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(14),
                            dashPattern: const [6, 6],
                            child: const Center(
                              child: Icon(Icons.add_photo_alternate_outlined),
                            ),
                          ),
                          onPick: controller.pickBannerPhotos,
                        ),
                        onRemoveLeading: controller.removePrimaryPhoto,
                        onRemove: controller.removeAdditionalPhoto,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CreateListingSection(
                title: 'Showcase Photos',
                description:
                    'Add separate highlight photos for the product showcase section of the asset page.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LNDText.medium(
                      text:
                          '${controller.showcasePhotos.length} / ${CreateListingController.maxShowcasePhotos} showcase photos uploaded',
                      color: colors.textMuted,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 10),
                    CreateListingPhotoGrid(
                      photos: controller.showcasePhotos,
                      maxCount: CreateListingController.maxShowcasePhotos,
                      onAdd: controller.pickShowcasePhotos,
                      addTrigger: _photoSourceMenu(
                        child: DottedBorder(
                          color: colors.outline,
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(14),
                          dashPattern: const [6, 6],
                          child: const Center(
                            child: Icon(Icons.add_photo_alternate_outlined),
                          ),
                        ),
                        onPick: controller.pickShowcasePhotosFromSource,
                      ),
                      onRemove: controller.removeShowcasePhoto,
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

  Widget _photoSourceMenu({
    required Widget child,
    required void Function(CreateListingPhotoSource source) onPick,
  }) {
    return LNDShow.popupMenuIcon<CreateListingPhotoSource>(
      icon: Icons.add_photo_alternate_outlined,
      child: child,
      items: [
        LNDMenuItem<CreateListingPhotoSource>(
          label: 'Camera',
          value: CreateListingPhotoSource.camera,
          icon: Icons.camera_alt_rounded,
          onTap: onPick,
        ),
        LNDMenuItem<CreateListingPhotoSource>(
          label: 'Gallery',
          value: CreateListingPhotoSource.gallery,
          icon: Icons.photo_library_rounded,
          onTap: onPick,
        ),
      ],
    );
  }
}
