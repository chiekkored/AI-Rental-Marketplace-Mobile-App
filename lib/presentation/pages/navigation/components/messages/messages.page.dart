import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/buttons.common.dart';
import 'package:lend/presentation/common/spinner.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/auth/auth.controller.dart';
import 'package:lend/presentation/controllers/messages/messages.controller.dart';
import 'package:lend/presentation/pages/navigation/components/messages/widgets/message_item.widget.dart';
import 'package:lend/presentation/pages/signin/signin.page.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';

class MessagesPage extends GetView<MessagesController> {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Obx(
          () => RefreshIndicator.adaptive(
            onRefresh: () async => controller.listenToChats(),
            child: CustomScrollView(
              controller: controller.scrollController,
              physics:
                  !controller.isAuthenticated
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                _buildBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        children: [
          Expanded(child: LNDText.bold(text: 'Messages', fontSize: 32.0)),
          Visibility(
            visible: controller.isAuthenticated,
            child: LNDButton.icon(
              icon: Icons.inventory_2_rounded,
              size: 25.0,
              onPressed: controller.goToArchivedMessagesPage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final colors = Get.context!.lndTheme;
    if (!controller.isAuthenticated) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _SigninView(),
      );
    }

    if (controller.isChatsLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: LNDSpinner()),
      );
    }

    if (controller.activeChats.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: LNDText.regular(
            text: 'No messages yet',
            color: colors.textMuted,
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: controller.activeChats.length,
      itemBuilder: (_, index) {
        final chat = controller.activeChats[index];
        // Get participant that is not the logged in user
        final participant = chat.participants?.firstWhereOrNull(
          (user) => user.uid != AuthController.instance.uid,
        );

        return MessageItemW(chat: chat, participant: participant);
      },
    );
  }
}

class _SigninView extends GetView<MessagesController> {
  const _SigninView();

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LNDText.bold(
              text: 'Sign in to view your messages',
              fontSize: 22.0,
              overflow: TextOverflow.visible,
            ),
            LNDText.regular(
              text:
                  'Stay connected with renters and respond to inquiries easily.',
              textAlign: TextAlign.center,
              color: colors.textMuted,
              overflow: TextOverflow.visible,
            ),
            LNDButton.primary(
              text: 'Sign in',
              enabled: true,
              onPressed:
                  controller.isAuthenticated
                      ? null
                      : () => Get.toNamed(SigninPage.routeName),
            ),
          ],
        ).withSpacing(24.0),
      ),
    );
  }
}
