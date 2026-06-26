import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lend/core/models/asset.model.dart';
import 'package:lend/core/models/location.model.dart';
import 'package:lend/presentation/controllers/create_listing/chunks/create_listing.chunk.dart';
import 'package:lend/presentation/controllers/location_picker/location_picker.controller.dart';
import 'package:lend/presentation/controllers/profile/profile.controller.dart';
import 'package:lend/utilities/helpers/loggers.helper.dart';
import 'package:lend/utilities/helpers/navigator.helper.dart';

class CreateListingLocationChunk implements CreateListingChunk {
  final formKey = GlobalKey<FormState>();
  final locationController = TextEditingController();

  final RxString locationText = ''.obs;
  final RxBool useCurrentLocation = true.obs;
  final RxBool currentLocationDenied = false.obs;
  final RxBool canContinue = false.obs;

  Location? _currentLocation;
  Location? _customLocation;

  final List<Worker> _workers = [];

  Location? get currentLocation => _currentLocation;

  Location? get customLocation => _customLocation;

  Location? get listingLocation =>
      useCurrentLocation.value
          ? ProfileController.instance.user?.location ?? _currentLocation
          : _customLocation;

  @override
  void onInit() {
    locationController.addListener(_updateCanContinue);
    _workers.add(ever<bool>(useCurrentLocation, (_) => _updateCanContinue()));
    _updateCanContinue();
  }

  void setInitialProfileLocationIfAvailable() {
    final profileLocation = ProfileController.instance.user?.location;
    if (profileLocation != null) {
      _currentLocation = profileLocation;
    }
    _updateCanContinue();
  }

  void populateFromAsset(Asset asset) {
    final profileLocation = ProfileController.instance.user?.location;
    useCurrentLocation.value = profileLocation == asset.location;

    if (useCurrentLocation.value) {
      _currentLocation = profileLocation;
      locationController.clear();
    } else {
      _customLocation = asset.location;
      locationController.text = asset.location?.description ?? '';
      locationText.value = locationController.text;
    }

    _updateCanContinue();
  }

  void loadFromDraft(Map<String, dynamic> draft) {
    useCurrentLocation.value = draft['useCurrentLocation'] as bool? ?? true;

    final profileLocation = ProfileController.instance.user?.location;
    final currentLocation = _locationFromDraft(draft['currentLocation']);
    final customLocation = _locationFromDraft(draft['customLocation']);

    _currentLocation = currentLocation ?? profileLocation;

    if (useCurrentLocation.value) {
      locationController.clear();
      locationText.value = '';
    } else {
      _customLocation = customLocation;
      locationController.text = _customLocation?.description ?? '';
      locationText.value = locationController.text;
    }

    _updateCanContinue();
  }

  Map<String, dynamic> toDraftMap() {
    return {
      'useCurrentLocation': useCurrentLocation.value,
      'currentLocation': _currentLocation?.toMap(),
      'customLocation': _customLocation?.toMap(),
    };
  }

  Future<void> toggleCurrentLocation(bool value) async {
    useCurrentLocation.value = value;

    if (!value) {
      _customLocation = null;
      locationController.clear();
      locationText.value = '';
      currentLocationDenied.value = false;
      _updateCanContinue();
      return;
    }

    final profileLocation = ProfileController.instance.user?.location;
    if (profileLocation != null) {
      _currentLocation = profileLocation;
      currentLocationDenied.value = false;
      _updateCanContinue();
      return;
    }

    await setDeviceLocationFallback();
  }

  Future<void> setDeviceLocationFallback() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        currentLocationDenied.value = true;
        useCurrentLocation.value = false;
        _customLocation = null;
        locationController.clear();
        locationText.value = '';
        _updateCanContinue();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentLocation = Location(
        formattedAddress: '',
        lat: position.latitude,
        lng: position.longitude,
      );
      currentLocationDenied.value = false;
      _updateCanContinue();
    } catch (e, st) {
      useCurrentLocation.value = false;
      _customLocation = null;
      locationController.clear();
      locationText.value = '';
      currentLocationDenied.value = true;
      _updateCanContinue();
      LNDLogger.e(e.toString(), error: e, stackTrace: st);
    }
  }

  Future<void> openLocationPicker() async {
    final result = await LNDNavigate.toPickLocationPage(
      args: LocationCallbackModel(
        useSpecificLocation: _customLocation?.useSpecificLocation ?? true,
        location:
            _customLocation ??
            Location(formattedAddress: locationController.text),
      ),
    );

    if (result == null) return;

    _customLocation = result.location;
    locationController.text = result.address;
    locationText.value = result.address;
    useCurrentLocation.value = false;
    _updateCanContinue();
  }

  Future<bool> ensureListingLocation() async {
    if (!useCurrentLocation.value) {
      return _customLocation != null &&
          (_customLocation?.description?.trim().isNotEmpty ?? false);
    }

    if (listingLocation != null &&
        (listingLocation?.description?.trim().isNotEmpty ?? false)) {
      return true;
    }

    await setDeviceLocationFallback();
    return listingLocation != null &&
        (listingLocation?.description?.trim().isNotEmpty ?? false);
  }

  Location? _locationFromDraft(dynamic value) {
    if (value is! Map) return null;
    return Location.fromMap(Map<String, dynamic>.from(value));
  }

  void _updateCanContinue() {
    if (useCurrentLocation.value) {
      canContinue.value = true;
      return;
    }

    canContinue.value =
        _customLocation != null &&
        (_customLocation?.description?.trim().isNotEmpty ?? false);

    locationText.value = locationController.text;
  }

  @override
  void onClose() {
    locationController.removeListener(_updateCanContinue);

    for (final worker in _workers) {
      worker.dispose();
    }

    locationText.close();
    useCurrentLocation.close();
    currentLocationDenied.close();
    canContinue.close();

    locationController.dispose();
  }
}
