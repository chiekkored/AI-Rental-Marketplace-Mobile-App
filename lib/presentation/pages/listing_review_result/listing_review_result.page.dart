import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/listing_review_result/listing_review_result.controller.dart';
import 'package:lend/presentation/pages/listing_review_result/components/listing_review_result_content.component.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class ListingReviewResultPage extends GetView<ListingReviewResultController> {
  static const routeName = '/listing-review-result';

  const ListingReviewResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(onPressed: Get.back),
        title: LNDText.bold(text: 'Listing Review', fontSize: 18.0),
      ),
      backgroundColor: colors.background,
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: LNDSpinner());
        }

        if (controller.submission == null) {
          return Center(
            child: LNDText.regular(
              text: 'Listing review not found.',
              color: colors.textMuted,
            ),
          );
        }

        return const ListingReviewResultContent();
      }),
    );
  }
}
