import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/presentation/controllers/messages/messages.controller.dart';
import 'package:lend/presentation/controllers/navigation/navigation.controller.dart';
import 'package:lend/presentation/controllers/notifications/notifications.controller.dart';
import 'package:lend/presentation/controllers/now/now.controller.dart';
import 'package:lend/presentation/controllers/saved/saved.controller.dart';
import 'package:lend/presentation/pages/navigation/components/home/home.page.dart';
import 'package:lend/presentation/pages/navigation/components/messages/messages.page.dart';
import 'package:lend/presentation/pages/navigation/components/now/now.page.dart';
import 'package:lend/presentation/pages/navigation/components/profile/profile.page.dart';
import 'package:lend/presentation/pages/saved/saved.page.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class NavigationPage extends GetView<NavigationController> {
  static const routeName = '/navigation';
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    const selectedIconSize = 35.0;
    const unselectedIconSize = 35.0;
    const badgeSize = 12.0;
    return PersistentTabView(
      backgroundColor: colors.surface,
      controller: controller.navigationController,
      navBarOverlap: const NavBarOverlap.none(),
      tabs: [
        PersistentTabConfig(
          item: ItemConfig(
            title: 'Discover',
            textStyle: LNDText.mediumStyle.copyWith(fontSize: 10.0),
            icon: const Icon(Icons.search_outlined, size: selectedIconSize + 3),
            inactiveIcon: const Icon(
              Icons.search_rounded,
              size: unselectedIconSize + 3,
            ),
            activeForegroundColor: colors.primary,
            inactiveForegroundColor: colors.unselected,
          ),
          onSelectedTabPressWhenNoScreensPushed:
              () => HomeController.instance.scrollToTop(),
          screen: const HomePage(),
        ),
        PersistentTabConfig(
          item: ItemConfig(
            title: 'Saved',
            textStyle: LNDText.mediumStyle.copyWith(fontSize: 10.0),
            icon: const Icon(Icons.bookmark_rounded, size: selectedIconSize),
            inactiveIcon: const Icon(
              Icons.bookmark_outline_rounded,
              size: unselectedIconSize,
            ),
            activeForegroundColor: colors.primary,
            inactiveForegroundColor: colors.unselected,
          ),
          onSelectedTabPressWhenNoScreensPushed:
              () => SavedController.instance.getSaved(),
          screen: const SavedPage(isTab: true),
        ),
        PersistentTabConfig(
          item: ItemConfig(
            title: 'Now',
            textStyle: LNDText.mediumStyle.copyWith(fontSize: 10.0),
            icon: Center(
              child: Obx(
                () => Badge(
                  smallSize: badgeSize,
                  padding: EdgeInsets.zero,
                  isLabelVisible: NowController.instance.hasHappeningToday,
                  child: const Icon(
                    Icons.today_rounded,
                    size: selectedIconSize,
                  ),
                ),
              ),
            ),
            inactiveIcon: Center(
              child: Obx(
                () => Badge(
                  smallSize: badgeSize,
                  padding: EdgeInsets.zero,
                  isLabelVisible: NowController.instance.hasHappeningToday,
                  child: const Icon(
                    Icons.today_outlined,
                    size: unselectedIconSize,
                  ),
                ),
              ),
            ),
            activeForegroundColor: colors.primary,
            inactiveForegroundColor: colors.unselected,
          ),
          onSelectedTabPressWhenNoScreensPushed:
              () => NowController.instance.scrollToTop(),
          screen: const NowPage(),
        ),
        PersistentTabConfig(
          item: ItemConfig(
            title: 'Messages',
            textStyle: LNDText.mediumStyle.copyWith(fontSize: 10.0),
            icon: Center(
              child: Obx(
                () => Badge(
                  smallSize: badgeSize,
                  padding: EdgeInsets.zero,
                  isLabelVisible: MessagesController.instance.unreadCount,
                  child: const Icon(
                    Icons.inbox_rounded,
                    size: selectedIconSize,
                  ),
                ),
              ),
            ),
            inactiveIcon: Center(
              child: Obx(
                () => Badge(
                  smallSize: badgeSize,
                  padding: EdgeInsets.zero,
                  isLabelVisible: MessagesController.instance.unreadCount,
                  child: const Icon(
                    Icons.inbox_outlined,
                    size: unselectedIconSize,
                  ),
                ),
              ),
            ),
            activeForegroundColor: colors.primary,
            inactiveForegroundColor: colors.unselected,
          ),
          onSelectedTabPressWhenNoScreensPushed:
              () => MessagesController.instance.scrollToTop(),
          screen: const MessagesPage(),
        ),
        PersistentTabConfig(
          item: ItemConfig(
            title: 'Profile',
            textStyle: LNDText.mediumStyle.copyWith(fontSize: 10.0),
            icon: Obx(
              () => Badge(
                smallSize: badgeSize,
                padding: EdgeInsets.zero,
                isLabelVisible:
                    NotificationsController.instance.hasUnreadNotifications,
                child: const Icon(
                  Icons.account_circle_rounded,
                  size: selectedIconSize,
                ),
              ),
            ),
            inactiveIcon: Obx(
              () => Badge(
                smallSize: badgeSize,
                padding: EdgeInsets.zero,
                isLabelVisible:
                    NotificationsController.instance.hasUnreadNotifications,
                child: const Icon(
                  Icons.account_circle_outlined,
                  size: unselectedIconSize,
                ),
              ),
            ),
            activeForegroundColor: colors.primary,
            inactiveForegroundColor: colors.unselected,
          ),
          screen: const ProfilePage(),
        ),
      ],
      navBarBuilder:
          (navBarConfig) => Style1BottomNavBar(
            navBarConfig: navBarConfig,
            navBarDecoration: NavBarDecoration(color: colors.surface),
          ),
    );
  }
}
