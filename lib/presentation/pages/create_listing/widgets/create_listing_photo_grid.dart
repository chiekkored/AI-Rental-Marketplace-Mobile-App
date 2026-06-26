import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/file.model.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CreateListingPhotoGrid extends StatelessWidget {
  final List<Rx<FileModel>> photos;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final int? maxCount;
  final bool showAddTile;
  final Widget? addTrigger;
  final Rx<FileModel>? leadingPhoto;
  final VoidCallback? onRemoveLeading;

  const CreateListingPhotoGrid({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    this.maxCount,
    this.showAddTile = true,
    this.addTrigger,
    this.leadingPhoto,
    this.onRemoveLeading,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    final photoCount = photos.length + (leadingPhoto == null ? 0 : 1);
    final showAdd = showAddTile && (maxCount == null || photoCount < maxCount!);
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        if (leadingPhoto != null)
          _PhotoTile(photo: leadingPhoto!, onRemove: onRemoveLeading),
        for (var i = 0; i < photos.length; i++)
          _PhotoTile(photo: photos[i], onRemove: () => onRemove(i)),
        if (showAdd)
          addTrigger ??
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onAdd,
                child: DottedBorder(
                  color: colors.outline,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(14),
                  dashPattern: const [6, 6],
                  child: const Center(
                    child: Icon(Icons.add_photo_alternate_outlined),
                  ),
                ),
              ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final Rx<FileModel> photo;
  final VoidCallback? onRemove;

  const _PhotoTile({required this.photo, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Obx(() {
      final localPath = photo.value.file?.path ?? '';
      final storagePath = photo.value.storagePath ?? '';
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (localPath.isNotEmpty)
              Image.file(File(localPath), fit: BoxFit.cover)
            else if (storagePath.isNotEmpty)
              LNDImage.custom(
                imageUrl: storagePath,
                height: double.infinity,
                width: double.infinity,
                borderRadius: 14,
              )
            else
              ColoredBox(color: colors.surfaceMuted),
            if ((photo.value.progress ?? 1) < 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _PhotoProgressBar(value: photo.value.progress),
              ),
            if (onRemove != null)
              Positioned(
                top: 4,
                right: 4,
                child: LNDButton.widget(
                  color: colors.surface,
                  borderRadius: 99,
                  size: 24,
                  onPressed: onRemove,
                  child: const Icon(Icons.close_rounded, size: 14),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _PhotoProgressBar extends StatelessWidget {
  final double? value;

  const _PhotoProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 4,
        color: context.lndTheme.primary,
        backgroundColor: context.lndTheme.surface.withValues(alpha: 0.35),
      ),
    );
  }
}
