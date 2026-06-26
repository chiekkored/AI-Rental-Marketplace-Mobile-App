import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/now/now.controller.dart';
import 'package:lend/presentation/pages/navigation/components/now/widgets/empty_now_section.widget.dart';
import 'package:lend/presentation/pages/navigation/components/now/widgets/now_booking_tile.widget.dart';
import 'package:lend/presentation/pages/navigation/components/now/widgets/now_signin_view.widget.dart';
import 'package:lend/presentation/pages/navigation/components/now/widgets/today_booking_card.widget.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';

class NowPage extends GetView<NowController> {
  const NowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SafeArea(
      child: Scaffold(
        backgroundColor: colors.background,
        body: Obx(() {
          if (!controller.isAuthenticated) {
            return const NowSigninView();
          }

          return RefreshIndicator.adaptive(
            onRefresh: () => controller.refreshNow(),
            child: CustomScrollView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: LNDText.bold(text: 'Now', fontSize: 32.0),
                  ),
                ),
                if (controller.isNowLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: LNDSpinner()),
                  )
                else ...[
                  SliverToBoxAdapter(child: _buildTodaySection()),
                  SliverToBoxAdapter(child: _buildIncomingSection()),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTodaySection() {
    final todayBookings = controller.todayNowBookings;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LNDText.bold(text: 'Today', fontSize: 16.0),
          const SizedBox(height: 12.0),
          if (todayBookings.isEmpty)
            const EmptyNowSection(text: 'No confirmed bookings today')
          else if (todayBookings.length == 1)
            Center(child: TodayBookingCard(item: todayBookings.first))
          else
            ...todayBookings.map((item) => NowBookingTile(item: item)),
        ],
      ),
    );
  }

  Widget _buildIncomingSection() {
    final incomingBookings = controller.incomingNowBookings;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LNDText.bold(text: 'Incoming', fontSize: 16.0),
          const SizedBox(height: 12.0),
          if (incomingBookings.isEmpty)
            const EmptyNowSection(text: 'No incoming confirmed bookings')
          else
            ...incomingBookings.map((item) => NowBookingTile(item: item)),
        ],
      ),
    );
  }
}
