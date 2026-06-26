// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class Location {
  String? plusCode;
  String? streetNumber;
  String? route;
  String? locality;
  String? administrativeAreaLevel2;
  String? administrativeAreaLevel1;
  String? country;
  String? countryShortName;
  String? postalCode;
  String? formattedAddress;
  double? lat;
  double? lng;
  String? geohash;
  bool? useSpecificLocation;

  Location({
    this.plusCode,
    this.streetNumber,
    this.route,
    this.locality,
    this.administrativeAreaLevel2,
    this.administrativeAreaLevel1,
    this.country,
    this.countryShortName,
    this.postalCode,
    this.formattedAddress,
    this.lat,
    this.lng,
    this.geohash,
    String? description,
    String? cityState,
    GeoPoint? latLng,
    this.useSpecificLocation,
  }) {
    formattedAddress ??= description;
    locality ??= cityState;
    if (latLng != null) {
      lat ??= latLng.latitude;
      lng ??= latLng.longitude;
    }
    geohash ??= _geohashFor(lat, lng);
  }

  String? get description => formattedAddress;
  String? get cityState => locality;
  GeoPoint? get latLng =>
      lat == null || lng == null ? null : GeoPoint(lat!, lng!);
  Location copyWith({
    String? plusCode,
    String? streetNumber,
    String? route,
    String? locality,
    String? administrativeAreaLevel2,
    String? administrativeAreaLevel1,
    String? country,
    String? countryShortName,
    String? postalCode,
    String? formattedAddress,
    double? lat,
    double? lng,
    String? geohash,
    String? description,
    String? cityState,
    GeoPoint? latLng,
    bool? useSpecificLocation,
  }) {
    final nextLat = latLng?.latitude ?? lat ?? this.lat;
    final nextLng = latLng?.longitude ?? lng ?? this.lng;
    return Location(
      plusCode: plusCode ?? this.plusCode,
      streetNumber: streetNumber ?? this.streetNumber,
      route: route ?? this.route,
      locality: locality ?? cityState ?? this.locality,
      administrativeAreaLevel2:
          administrativeAreaLevel2 ?? this.administrativeAreaLevel2,
      administrativeAreaLevel1:
          administrativeAreaLevel1 ?? this.administrativeAreaLevel1,
      country: country ?? this.country,
      countryShortName: countryShortName ?? this.countryShortName,
      postalCode: postalCode ?? this.postalCode,
      formattedAddress:
          formattedAddress ?? description ?? this.formattedAddress,
      lat: nextLat,
      lng: nextLng,
      geohash: geohash ?? _geohashFor(nextLat, nextLng) ?? this.geohash,
      useSpecificLocation: useSpecificLocation ?? this.useSpecificLocation,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'plusCode': plusCode,
      'streetNumber': streetNumber,
      'route': route,
      'locality': locality,
      'administrativeAreaLevel2': administrativeAreaLevel2,
      'administrativeAreaLevel1': administrativeAreaLevel1,
      'country': country,
      'countryShortName': countryShortName,
      'postalCode': postalCode,
      'formattedAddress': formattedAddress,
      'lat': lat,
      'lng': lng,
      'geohash': geohash ?? _geohashFor(lat, lng),
    }..removeWhere((key, value) => value == null);
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    final legacyGeoPoint = _geoPointFromValue(map['latLng']);
    final lat = _doubleValue(map['lat']) ?? legacyGeoPoint?.latitude;
    final lng = _doubleValue(map['lng']) ?? legacyGeoPoint?.longitude;

    return Location(
      plusCode: _stringValue(map['plusCode']),
      streetNumber: _stringValue(map['streetNumber']),
      route: _stringValue(map['route']),
      locality: _stringValue(map['locality']) ?? _stringValue(map['cityState']),
      administrativeAreaLevel2: _stringValue(map['administrativeAreaLevel2']),
      administrativeAreaLevel1: _stringValue(map['administrativeAreaLevel1']),
      country: _stringValue(map['country']),
      countryShortName: _stringValue(map['countryShortName']),
      postalCode: _stringValue(map['postalCode']),
      formattedAddress:
          _stringValue(map['formattedAddress']) ??
          _stringValue(map['description']),
      lat: lat,
      lng: lng,
      geohash: _stringValue(map['geohash']) ?? _geohashFor(lat, lng),
      useSpecificLocation:
          map['useSpecificLocation'] is bool
              ? map['useSpecificLocation'] as bool
              : null,
    );
  }

  factory Location.fromLatLng({
    required double lat,
    required double lng,
    String? formattedAddress,
    String? locality,
    String? country,
  }) {
    return Location(
      formattedAddress: formattedAddress,
      locality: locality,
      country: country,
      lat: lat,
      lng: lng,
    );
  }

  String toJson() => json.encode(toMap());

  factory Location.fromJson(String source) =>
      Location.fromMap(json.decode(source) as Map<String, dynamic>);

  static String? _geohashFor(double? lat, double? lng) {
    if (lat == null || lng == null) return null;
    return GeoFirePoint(GeoPoint(lat, lng)).geohash;
  }

  static String? _stringValue(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static double? _doubleValue(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static GeoPoint? _geoPointFromValue(dynamic value) {
    if (value == null) return null;
    if (value is GeoPoint) return value;
    if (value is Map) {
      final lat = _doubleValue(value['latitude']);
      final lng = _doubleValue(value['longitude']);
      if (lat != null && lng != null) return GeoPoint(lat, lng);
    }
    return null;
  }

  @override
  String toString() {
    return 'Location(plusCode: $plusCode, streetNumber: $streetNumber, route: $route, locality: $locality, administrativeAreaLevel2: $administrativeAreaLevel2, administrativeAreaLevel1: $administrativeAreaLevel1, country: $country, countryShortName: $countryShortName, postalCode: $postalCode, formattedAddress: $formattedAddress, lat: $lat, lng: $lng, geohash: $geohash, useSpecificLocation: $useSpecificLocation)';
  }

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;
    if (other is! Location) return false;

    return other.plusCode == plusCode &&
        other.streetNumber == streetNumber &&
        other.route == route &&
        other.locality == locality &&
        other.administrativeAreaLevel2 == administrativeAreaLevel2 &&
        other.administrativeAreaLevel1 == administrativeAreaLevel1 &&
        other.country == country &&
        other.countryShortName == countryShortName &&
        other.postalCode == postalCode &&
        other.formattedAddress == formattedAddress &&
        other.lat == lat &&
        other.lng == lng &&
        other.geohash == geohash &&
        other.useSpecificLocation == useSpecificLocation;
  }

  @override
  int get hashCode =>
      plusCode.hashCode ^
      streetNumber.hashCode ^
      route.hashCode ^
      locality.hashCode ^
      administrativeAreaLevel2.hashCode ^
      administrativeAreaLevel1.hashCode ^
      country.hashCode ^
      countryShortName.hashCode ^
      postalCode.hashCode ^
      formattedAddress.hashCode ^
      lat.hashCode ^
      lng.hashCode ^
      geohash.hashCode ^
      useSpecificLocation.hashCode;
}
