import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lend/presentation/controllers/booking_details/booking_details.controller.dart';

class BookingDetailsLocationMap extends GetView<BookingDetailsController> {
  const BookingDetailsLocationMap({super.key});

  @override
  Widget build(BuildContext context) {
    final center = controller.mapCenter;
    if (center == null) return const SizedBox.shrink();

    return SizedBox(
      height: 140.0,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: GoogleMap(
          buildingsEnabled: false,
          initialCameraPosition: controller.cameraPosition,
          markers: {
            Marker(
              markerId: const MarkerId('booking-details-booking-location'),
              position: center,
            ),
          },
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
    );
  }
}
