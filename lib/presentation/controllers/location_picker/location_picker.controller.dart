import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/presentation/common/show.common.dart';
import 'package:lend/presentation/common/snackbar.common.dart';
import 'package:lend/presentation/controllers/home/home.controller.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationCallbackModel {
  final Location location;
  final bool useSpecificLocation;

  LocationCallbackModel({
    required this.location,
    required this.useSpecificLocation,
  });

  String get address => location.formattedAddress ?? '';
  String get country => location.country ?? '';
  String get locality => location.locality ?? '';
  String get cityState => location.locality ?? '';
  LatLng? get latLng =>
      location.lat == null || location.lng == null
          ? null
          : LatLng(location.lat!, location.lng!);
}

class LocationPickerController extends GetxController {
  final LocationCallbackModel? locationCallback;
  LocationPickerController({this.locationCallback});

  static final LocationPickerController instance =
      Get.find<LocationPickerController>();

  final locationController = TextEditingController();

  final currentLatLng = HomeController.instance.activeBrowseLocation?.latLng;

  final _zoomLevel = 16.0;

  late Rx<CameraPosition> cameraPosition =
      CameraPosition(
        target: LatLng(
          currentLatLng?.latitude ?? 0.0,
          currentLatLng?.longitude ?? 0.0,
        ),
        zoom: 14.0,
      ).obs;

  late final Rx<LatLng> _currentPosition =
      LatLng(
        currentLatLng?.latitude ?? 0.0,
        currentLatLng?.longitude ?? 0.0,
      ).obs;

  final Rx<LatLng?> _pinnedPosition = Rx(null);
  LatLng? get pinnedPosition => _pinnedPosition.value;

  bool _selectingPlace = false;

  final marker = <Marker>{}.obs;
  final circle = <Circle>{}.obs;

  final RxBool useSpecificLocation = true.obs;
  final RxBool _isConfirmingLocation = false.obs;
  bool get isConfirmingLocation => _isConfirmingLocation.value;

  GoogleMapController? mapController;

  @override
  void onClose() {
    locationController.dispose();
    mapController?.dispose();
    cameraPosition.close();
    _currentPosition.close();
    _pinnedPosition.close();
    marker.close();
    circle.close();
    useSpecificLocation.close();
    _isConfirmingLocation.close();

    super.onClose();
  }

  @override
  void onInit() {
    ever(useSpecificLocation, (_) => _toggleLocationUsage());

    super.onInit();
  }

  @override
  void onReady() {
    if (locationCallback != null) {
      _setInitialValues();
    } else {
      getToCurrentLocation();
    }
    super.onReady();
  }

  void _setInitialValues() {
    if (locationCallback != null) {
      locationController.text = locationCallback?.address ?? '';
      useSpecificLocation.value = locationCallback?.useSpecificLocation ?? true;

      if (locationCallback?.latLng != null) {
        selectPlaceLocation(
          LatLng(
            locationCallback?.latLng?.latitude ?? 0.0,
            locationCallback?.latLng?.longitude ?? 0.0,
          ),
        );
      } else {
        getToCurrentLocation();
      }
    }
  }

  Future<void> getToCurrentLocation() async {
    try {
      // Request permission first
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _showPermissionDeniedMessage();
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update camera position
      cameraPosition.value = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: _zoomLevel,
      );
      _pinnedPosition.value = cameraPosition.value.target;
      // _addMarker(cameraPosition.value.target);

      // Update current location
      _currentPosition.value = LatLng(position.latitude, position.longitude);

      // If map is already created, animate to the position
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition.value),
        );
      }
      locationController.clear();
    } catch (e, st) {
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // If we already have location, move camera to it
    if (cameraPosition.value.target.latitude != 0) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition.value),
      );
    }
  }

  void selectPlaceLocation(LatLng latLng) {
    _selectingPlace = true;
    // _addMarker(latLng);

    // Update camera position
    cameraPosition.value = CameraPosition(target: latLng, zoom: _zoomLevel);

    // Animate camera to new position
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition.value),
    );

    _pinnedPosition.value = latLng;
  }

  void updateCameraWithMarker(LatLng latLng) {
    selectPlaceLocation(latLng);
  }

  void updatePinnedPositionFromCamera(CameraPosition position) {
    cameraPosition.value = position;
    _pinnedPosition.value = position.target;
    if (!_selectingPlace) {
      marker.clear();
      circle.clear();
    }
  }

  void onCameraIdle() {
    _selectingPlace = false;
  }

  // void _addMarker(LatLng latLng) {
  //   // Clear previous markers
  //   marker.clear();
  //   circle.clear();

  //   // Add new marker or circle based on the useSpecificLocation value
  //   if (useSpecificLocation.isTrue) {
  //     // Add new marker
  //     marker.add(
  //       Marker(markerId: const MarkerId('selected-location'), position: latLng),
  //     );
  //   } else {
  //     // Add new circle
  //     final color =
  //         Get.context?.lndTheme.info ??
  //         Theme.of(Get.context!).colorScheme.secondary;
  //     circle.add(
  //       Circle(
  //         circleId: const CircleId('selected-location'),
  //         center: latLng,
  //         radius: 500,
  //         fillColor: color.withValues(alpha: 0.5),
  //         strokeColor: color,
  //         strokeWidth: 1,
  //       ),
  //     );
  //   }
  // }

  void _showPermissionDeniedMessage() {
    LNDShow.alertDialog(
      title: 'Location Access Denied',
      content:
          'You have previously denied location access. Please go to Settings '
          'to enable it.',
      cancelText: 'Close',
      confirmText: 'Settings',
      onConfirm: () async {
        final canOpen = await openAppSettings();

        if (!canOpen) {
          LNDSnackbar.showWarning(
            "Unable to open app settings. Open phone's settings and enable "
            'location access manually.',
          );
        }
      },
    );
  }

  void clearLocation() {
    locationController.clear();
    marker.clear();
    circle.clear();
    _pinnedPosition.value = cameraPosition.value.target;
  }

  void _toggleLocationUsage() {
    if (_pinnedPosition.value != null) {
      // _addMarker(_pinnedPosition.value!);
    }
  }

  void setAddressDetails(Prediction? prediction) {
    final position =
        prediction?.lat != null && prediction?.lng != null
            ? LatLng(
              double.tryParse(prediction?.lat ?? '') ?? 0.0,
              double.tryParse(prediction?.lng ?? '') ?? 0.0,
            )
            : _pinnedPosition.value;

    if (position != null) selectPlaceLocation(position);
  }

  Future<void> applyLocation() async {
    final location = await confirmSelectedLocation();
    if (location != null) {
      Get.back<LocationCallbackModel>(result: location);
      return;
    }
  }

  LocationCallbackModel? get selectedLocation {
    final position = _pinnedPosition.value;
    if (position == null) return null;

    return LocationCallbackModel(
      useSpecificLocation: useSpecificLocation.value,
      location: Location.fromLatLng(
        lat: position.latitude,
        lng: position.longitude,
        formattedAddress: locationController.text.trim(),
      ),
    );
  }

  Future<LocationCallbackModel?> confirmSelectedLocation() async {
    final position = _pinnedPosition.value;
    if (position == null) {
      LNDSnackbar.showError('Select a location to continue.');
      return null;
    }

    final apiKey = dotenv.env['GOOGLE_MAPS_GEOCODING_API_KEY']?.trim() ?? '';
    if (apiKey.isEmpty) {
      LNDSnackbar.showError('Google Maps Geocoding API key is not configured.');
      return null;
    }

    try {
      _isConfirmingLocation.value = true;
      final response = await Dio().get<Map<String, dynamic>>(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '${position.latitude},${position.longitude}',
          'key': apiKey,
        },
      );

      final data = response.data;
      final status = data?['status'] as String?;
      final results = data?['results'];
      if (status != 'OK' || results is! List || results.isEmpty) {
        LNDSnackbar.showError('Unable to find an address for this location.');
        return null;
      }

      final result = results.first;
      if (result is! Map<String, dynamic>) {
        LNDSnackbar.showError('Unable to find an address for this location.');
        return null;
      }

      final address = (result['formatted_address'] as String?)?.trim() ?? '';
      final components = result['address_components'];
      final geometry = result['geometry'];
      final geocodedLocation =
          geometry is Map<String, dynamic> ? geometry['location'] : null;
      final lat =
          geocodedLocation is Map<String, dynamic>
              ? _doubleValue(geocodedLocation['lat']) ?? position.latitude
              : position.latitude;
      final lng =
          geocodedLocation is Map<String, dynamic>
              ? _doubleValue(geocodedLocation['lng']) ?? position.longitude
              : position.longitude;
      final country = _addressComponentValue(components, 'country');

      if (address.isEmpty || country.isEmpty) {
        LNDSnackbar.showError('Unable to find an address for this location.');
        return null;
      }

      return LocationCallbackModel(
        location: Location(
          plusCode: _plusCodeFromResult(result['plus_code']),
          streetNumber: _addressComponentValue(components, 'street_number'),
          route: _addressComponentValue(components, 'route'),
          locality: _addressComponentValue(components, 'locality'),
          administrativeAreaLevel2: _addressComponentValue(
            components,
            'administrative_area_level_2',
          ),
          administrativeAreaLevel1: _addressComponentValue(
            components,
            'administrative_area_level_1',
          ),
          country: country,
          countryShortName: _addressComponentShortValue(components, 'country'),
          postalCode: _addressComponentValue(components, 'postal_code'),
          formattedAddress: address,
          lat: lat,
          lng: lng,
          useSpecificLocation: useSpecificLocation.value,
        ),
        useSpecificLocation: useSpecificLocation.value,
      );
    } catch (e, st) {
      LNDLogger.e(
        'Error reverse geocoding pinned location',
        error: e,
        stackTrace: st,
      );
      LNDSnackbar.showError('Unable to find an address for this location.');
      return null;
    } finally {
      _isConfirmingLocation.value = false;
    }
  }

  String _addressComponentValue(Object? components, String type) {
    if (components is! List) return '';

    for (final component in components) {
      if (component is! Map<String, dynamic>) continue;
      final types = component['types'];
      if (types is! List || !types.contains(type)) continue;

      return (component['long_name'] as String?)?.trim() ?? '';
    }

    return '';
  }

  String _addressComponentShortValue(Object? components, String type) {
    if (components is! List) return '';

    for (final component in components) {
      if (component is! Map<String, dynamic>) continue;
      final types = component['types'];
      if (types is! List || !types.contains(type)) continue;

      return (component['short_name'] as String?)?.trim() ?? '';
    }

    return '';
  }

  String? _plusCodeFromResult(Object? plusCode) {
    if (plusCode is! Map<String, dynamic>) return null;
    return (plusCode['global_code'] as String?)?.trim().isNotEmpty == true
        ? (plusCode['global_code'] as String).trim()
        : (plusCode['compound_code'] as String?)?.trim();
  }

  double? _doubleValue(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
