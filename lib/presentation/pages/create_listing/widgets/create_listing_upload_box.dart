import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/file.model.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class CreateListingUploadBox extends StatelessWidget {
  final String text;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? actionTrigger;
  final Rx<FileModel>? photo;
  final VoidCallback? onRemove;
  final bool hasError;

  const CreateListingUploadBox({
    super.key,
    required this.text,
    required this.subtitle,
    required this.onTap,
    this.actionTrigger,
    this.photo,
    this.onRemove,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return DottedBorder(
      color: hasError ? colors.danger : colors.outline,
      borderType: BorderType.RRect,
      radius: const Radius.circular(16),
      dashPattern: const [7, 6],
      strokeWidth: 1.5,
      child: SizedBox(
        height: 168,
        width: double.infinity,
        child:
            photo == null
                ? Stack(
                  fit: StackFit.expand,
                  children: [
                    _UploadPrompt(text: text, subtitle: subtitle),
                    actionTrigger ??
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: onTap,
                        ),
                  ],
                )
                : InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onTap,
                  child: Obx(() {
                    final localPath = photo!.value.file?.path ?? '';
                    final storagePath = photo!.value.storagePath ?? '';
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child:
                              localPath.isNotEmpty
                                  ? Image.file(
                                    File(localPath),
                                    fit: BoxFit.cover,
                                  )
                                  : storagePath.isEmpty
                                  ? _UploadPrompt(
                                    text: text,
                                    subtitle: subtitle,
                                  )
                                  : LNDImage.custom(
                                    imageUrl: storagePath,
                                    height: 168,
                                    width: double.infinity,
                                    borderRadius: 14,
                                  ),
                        ),
                        if ((photo!.value.progress ?? 1) < 1)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _UploadProgressBar(
                              value: photo!.value.progress,
                            ),
                          ),
                        if (onRemove != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: LNDButton.widget(
                              color: colors.surface,
                              borderRadius: 99,
                              size: 32,
                              onPressed: onRemove,
                              child: const Icon(Icons.close_rounded, size: 18),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
      ),
    );
  }
}

class _UploadProgressBar extends StatelessWidget {
  final double? value;

  const _UploadProgressBar({required this.value});

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

class _UploadPrompt extends StatelessWidget {
  final String text;
  final String subtitle;

  const _UploadPrompt({required this.text, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, color: context.lndTheme.primary),
        const SizedBox(height: 10),
        LNDText.bold(text: text, fontSize: 14),
        const SizedBox(height: 4),
        LNDText.regular(
          text: subtitle,
          fontSize: 12,
          color: context.lndTheme.textMuted,
        ),
      ],
    );
  }
}
