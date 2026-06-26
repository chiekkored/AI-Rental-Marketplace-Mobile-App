import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/rental_history/rental_history.controller.dart';
import 'package:lend/presentation/pages/rental_history/widgets/rental_history_booking_tile.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class RentalHistoryPage extends GetView<RentalHistoryController> {
  static const routeName = '/rental-history';

  const RentalHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        surfaceTintColor: colors.surface,
        backgroundColor: colors.surface,
        leading: LNDButton.back(),
        title: LNDText.bold(text: 'Rental History', fontSize: 18.0),
      ),
      body: SafeArea(
        child: Obx(
          () => RefreshIndicator.adaptive(
            onRefresh: () => controller.getBookings(forceRefresh: true),
            child: CustomScrollView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (controller.isLoading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: LNDSpinner(color: colors.textPrimary)),
                  )
                else if (controller.bookings.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: LNDText.regular(
                        text: 'No rental history yet',
                        color: colors.textMuted,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    sliver: SliverList.builder(
                      itemCount: controller.bookings.length,
                      itemBuilder: (_, index) {
                        final booking = controller.bookings[index];
                        return RentalHistoryBookingTile(
                          booking: booking,
                          onTap: () => controller.openChat(booking),
                        );
                      },
                    ),
                  ),
                if (controller.isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: LNDSpinner(color: colors.textPrimary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
