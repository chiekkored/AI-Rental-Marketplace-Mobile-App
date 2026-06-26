import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lend/core/models/simple_user.model.dart';
import 'package:lend/presentation/common/images.common.dart';
import 'package:lend/presentation/common/texts.common.dart';
import 'package:lend/presentation/common/verified_name.common.dart';
import 'package:lend/presentation/controllers/asset/asset.controller.dart';
import 'package:lend/utilities/enums/image_type.enum.dart';
import 'package:lend/utilities/extensions/string.extension.dart';
import 'package:lend/utilities/extensions/theme_context.extension.dart';
import 'package:lend/utilities/extensions/widget.extension.dart';
import 'package:lend/utilities/helpers/utilities.helper.dart';
import 'package:shimmer/shimmer.dart';

String assetOwnerDisplayName({
  required bool isCurrentUserOwner,
  required SimpleUserModel? owner,
}) {
  final name = LNDUtils.formatSimpleUserName(owner);
  return isCurrentUserOwner ? name : name.toObscure();
}

class AssetUserDetails extends GetView<AssetController> {
  const AssetUserDetails({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.lndTheme;
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        color: colors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40.0,
              child: Obx(
                () =>
                    controller.isUserLoading
                        ? Shimmer.fromColors(
                          baseColor: colors.outline,
                          highlightColor: colors.surface,
                          child: Row(
                            children: [
                              CircleAvatar(backgroundColor: colors.surface),
                              Container(
                                height: 20.0,
                                width: 200.0,
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                            ],
                          ).withSpacing(8.0),
                        )
                        : GestureDetector(
                          child: Row(
                            children: [
                              LNDImage.circle(
                                imageUrl: controller.asset?.owner?.photoUrl,
                                size: 40.0,
                                imageType: ImageType.user,
                              ),
                              const SizedBox(width: 8.0),
                              Flexible(
                                child: LNDVerifiedName(
                                  name: assetOwnerDisplayName(
                                    isCurrentUserOwner:
                                        controller.isCurrentUserOwner,
                                    owner: controller.asset?.owner,
                                  ),
                                  verificationLevel:
                                      controller.asset?.owner?.verified,
                                  showBusinessBadge:
                                      controller.asset?.owner?.hasDisplayName ==
                                      true,
                                  showFoundingOwnerBadge:
                                      controller
                                          .asset
                                          ?.owner
                                          ?.isFoundingOwnerAccount ==
                                      true,
                                  weight: LNDVerifiedNameWeight.bold,
                                  badgeSize: 15.0,
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.locationDot,
                            color: colors.outline,
                            size: 20.0,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Obx(
                              () => LNDText.regular(
                                text: LNDUtils.getLocationText(
                                  location: controller.asset?.location,
                                  showFullAddress: false,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // LNDButton.icon(
                    //   icon: FontAwesomeIcons.angleRight,
                    //   onPressed: () {},
                    //   size: 20.0,
                    // ),
                  ],
                ),
                SizedBox(
                  height: 100.0,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Obx(
                      () => GoogleMap(
                        buildingsEnabled: false,
                        initialCameraPosition: controller.cameraPosition,
                        onMapCreated: controller.onMapCreated,
                        circles: controller.circles.toSet(),
                        markers: controller.markers.toSet(),
                        myLocationButtonEnabled: false,
                        zoomGesturesEnabled: false,
                        scrollGesturesEnabled: false,
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                        myLocationEnabled: false,
                        tiltGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                      ),
                    ),
                  ),
                ),
              ],
            ).withSpacing(16.0),
          ],
        ).withSpacing(16.0),
      ),
    );
  }
}
