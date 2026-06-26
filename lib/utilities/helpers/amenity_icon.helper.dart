import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AmenityIcon {
  final IconData icon;
  final double size;

  const AmenityIcon({required this.icon, required this.size});
}

AmenityIcon amenityIconFromKey(String? key) {
  final iconEntry = _amenityIconRegistry[_normalizeAmentityIconKey(key)];
  if (iconEntry != null) {
    return iconEntry;
  }
  return const AmenityIcon(icon: FontAwesomeIcons.box, size: 24);
}

String _normalizeAmentityIconKey(String? key) {
  return key?.trim().replaceAll(RegExp(r'[\s_-]+'), '').toLowerCase() ?? '';
}

const Map<String, AmenityIcon> _amenityIconRegistry = {
  'wifi': AmenityIcon(icon: FontAwesomeIcons.wifi, size: 24),
  'airconditioning': AmenityIcon(icon: FontAwesomeIcons.snowflake, size: 24),
  'electricfan': AmenityIcon(icon: FontAwesomeIcons.fan, size: 24),
  'hotwater': AmenityIcon(icon: FontAwesomeIcons.mugHot, size: 24),
  'kitchen': AmenityIcon(icon: FontAwesomeIcons.fireBurner, size: 24),
  'refrigerator': AmenityIcon(icon: Icons.kitchen_rounded, size: 32),
  'microwave': AmenityIcon(icon: Icons.microwave_rounded, size: 32),
  'ricecooker': AmenityIcon(icon: FontAwesomeIcons.bowlRice, size: 24),
  'electrickettle': AmenityIcon(icon: FontAwesomeIcons.mugSaucer, size: 24),
  'waterdispenser': AmenityIcon(
    icon: FontAwesomeIcons.glassWaterDroplet,
    size: 24,
  ),
  'cookware': AmenityIcon(icon: FontAwesomeIcons.kitchenSet, size: 24),
  'diningtable': AmenityIcon(icon: Icons.table_restaurant_rounded, size: 32),
  'privatebathroom': AmenityIcon(icon: FontAwesomeIcons.bath, size: 24),
  'bidet': AmenityIcon(icon: FontAwesomeIcons.toiletPaper, size: 24),
  'towels': AmenityIcon(icon: Icons.dry_cleaning_rounded, size: 32),
  'bedsheets': AmenityIcon(icon: FontAwesomeIcons.mattressPillow, size: 24),
  'tv': AmenityIcon(icon: FontAwesomeIcons.tv, size: 24),
  'washingmachine': AmenityIcon(
    icon: Icons.local_laundry_service_rounded,
    size: 32,
  ),
  'iron': AmenityIcon(icon: Icons.iron_rounded, size: 32),
  'carparking': AmenityIcon(icon: FontAwesomeIcons.car, size: 24),
  'motorcycleparking': AmenityIcon(icon: FontAwesomeIcons.motorcycle, size: 24),
  'elevator': AmenityIcon(icon: FontAwesomeIcons.elevator, size: 24),
  'privateentrance': AmenityIcon(icon: FontAwesomeIcons.doorClosed, size: 24),
  'selfcheckin': AmenityIcon(icon: FontAwesomeIcons.personBooth, size: 24),
  'pool': AmenityIcon(icon: FontAwesomeIcons.waterLadder, size: 24),
  'balcony': AmenityIcon(icon: Icons.balcony_rounded, size: 32),
  'garden': AmenityIcon(icon: FontAwesomeIcons.leaf, size: 24),
  'bbqgrill': AmenityIcon(icon: Icons.outdoor_grill_rounded, size: 32),
  'beachaccess': AmenityIcon(icon: FontAwesomeIcons.umbrellaBeach, size: 24),
  'seaview': AmenityIcon(icon: FontAwesomeIcons.water, size: 24),
  'mountainview': AmenityIcon(icon: FontAwesomeIcons.mountain, size: 24),
  'fireextinguisher': AmenityIcon(
    icon: FontAwesomeIcons.fireExtinguisher,
    size: 24,
  ),
  'firstaidkit': AmenityIcon(icon: FontAwesomeIcons.kitMedical, size: 24),
  'cctv': AmenityIcon(icon: Icons.camera_indoor_rounded, size: 32),
  'securityguard': AmenityIcon(
    icon: FontAwesomeIcons.personMilitaryPointing,
    size: 24,
  ),
  'generator': AmenityIcon(icon: FontAwesomeIcons.chargingStation, size: 24),
  'watertank': AmenityIcon(
    icon: FontAwesomeIcons.arrowUpFromWaterPump,
    size: 24,
  ),
  'tables': AmenityIcon(icon: Icons.table_bar_rounded, size: 32),
  'chairs': AmenityIcon(icon: FontAwesomeIcons.chair, size: 24),
  'soundsystem': AmenityIcon(icon: FontAwesomeIcons.bullhorn, size: 24),
  'microphones': AmenityIcon(icon: FontAwesomeIcons.microphone, size: 24),
  'projector': AmenityIcon(icon: FontAwesomeIcons.sun, size: 24),
  'lightingequipment': AmenityIcon(
    icon: FontAwesomeIcons.solidLightbulb,
    size: 24,
  ),
  'poweroutlets': AmenityIcon(icon: FontAwesomeIcons.plug, size: 24),
  'extensioncords': AmenityIcon(icon: Icons.cable_rounded, size: 32),
  'restroom': AmenityIcon(icon: FontAwesomeIcons.restroom, size: 24),
  'dressingroom': AmenityIcon(icon: FontAwesomeIcons.shirt, size: 24),
  'storagearea': AmenityIcon(icon: FontAwesomeIcons.boxesPacking, size: 24),
  'loadingarea': AmenityIcon(icon: FontAwesomeIcons.truckRampBox, size: 24),
  'cleaningavailable': AmenityIcon(icon: FontAwesomeIcons.broom, size: 24),
  'staffassistance': AmenityIcon(
    icon: FontAwesomeIcons.personCircleQuestion,
    size: 24,
  ),
};
