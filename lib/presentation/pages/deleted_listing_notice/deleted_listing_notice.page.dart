import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/deleted_listing_notice/deleted_listing_notice.controller.dart';
import 'package:lend/presentation/pages/deleted_listing_notice/components/deleted_listing_notice_content.component.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class DeletedListingNoticePage extends GetView<DeletedListingNoticeController> {
  static const routeName = '/deleted-listing-notice';

  const DeletedListingNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(onPressed: Get.back),
        title: LNDText.bold(text: 'Listing Notice', fontSize: 18.0),
      ),
      backgroundColor: colors.background,
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: LNDSpinner());
        }

        if (controller.event == null) {
          return Center(
            child: LNDText.regular(
              text: 'Listing notice not found.',
              color: colors.textMuted,
            ),
          );
        }

        return const DeletedListingNoticeContent();
      }),
    );
  }
}
