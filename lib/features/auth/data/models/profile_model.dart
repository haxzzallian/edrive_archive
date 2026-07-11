// lib/features/profile_setup/data/models/profile_model.dart
import 'dart:convert';
import '../../domain/entities/profile_entity.dart';

class LocationModel {
  final String state;
  final String lga;
  final String address;
  final double lat;
  final double lng;

  const LocationModel({
    required this.state,
    required this.lga,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory LocationModel.fromJson(Map<String, dynamic> j) => LocationModel(
        state: j['state'] ?? '',
        lga: j['lga'] ?? '',
        address: j['address'] ?? '',
        lat: (j['coordinates']?['lat'] as num?)?.toDouble() ?? 6.5244,
        lng: (j['coordinates']?['lng'] as num?)?.toDouble() ?? 3.3792,
      );

  /// Serialises to the JSON string the API expects
  String toApiString() => jsonEncode({
        'state': state,
        'lga': lga,
        'address': address,
        'coordinates': {'lat': lat, 'lng': lng},
      });

  LocationEntity toEntity() => LocationEntity(
        state: state,
        lga: lga,
        address: address,
        lat: lat,
        lng: lng,
      );
}

class CarDetailsModel {
  final String model;
  final String product;
  final int year;
  final String color;
  final String plateNumber;

  const CarDetailsModel({
    required this.model,
    required this.product,
    required this.year,
    required this.color,
    required this.plateNumber,
  });

  factory CarDetailsModel.fromJson(Map<String, dynamic> j) => CarDetailsModel(
        model: j['model'] ?? '',
        product: j['product'] ?? '',
        year: (j['year'] as num?)?.toInt() ?? 0,
        color: j['color'] ?? '',
        plateNumber: j['plateNumber'] ?? '',
      );

  /// Serialises to the JSON string the API expects
  String toApiString() => jsonEncode({
        'model': model,
        'product': product,
        'year': year,
        'color': color,
        'plateNumber': plateNumber,
      });

  CarDetailsEntity toEntity() => CarDetailsEntity(
        model: model,
        product: product,
        year: year,
        color: color,
        plateNumber: plateNumber,
      );
}

class ProfileModel {
  final String userId;
  final String userEmail;
  final bool isDriver;
  final String gender;
  final LocationModel location;
  final String phoneNumber;
  final String? profilePicture;
  final String? carPicture;
  final String? driverLicense;
  final CarDetailsModel? carDetails;
  final String? maritalStatus;
  final String? yoe;
  final String? currentLocation;
  final String? languageSpoken;
  final String? gearType;
  final String? vehicleType;
  final List<String> driverRoles;
  final bool interstate;
  final String? question;
  final double ratings;
  final bool verified;

  const ProfileModel({
    required this.userId,
    required this.userEmail,
    required this.isDriver,
    required this.gender,
    required this.location,
    required this.phoneNumber,
    this.profilePicture,
    this.carPicture,
    this.driverLicense,
    this.carDetails,
    this.maritalStatus,
    this.yoe,
    this.currentLocation,
    this.languageSpoken,
    this.gearType,
    this.vehicleType,
    this.driverRoles = const [],
    this.interstate = false,
    this.question,
    this.ratings = 0,
    this.verified = false,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> j) {
    // location can come as a JSON string or a Map
    LocationModel location;
    final rawLoc = j['location'];
    if (rawLoc is String) {
      location =
          LocationModel.fromJson(jsonDecode(rawLoc) as Map<String, dynamic>);
    } else if (rawLoc is Map) {
      location = LocationModel.fromJson(rawLoc as Map<String, dynamic>);
    } else {
      location =
          const LocationModel(state: '', lga: '', address: '', lat: 0, lng: 0);
    }

    // carDetails can come as a JSON string or a Map
    CarDetailsModel? carDetails;
    final rawCar = j['carDetails'];
    if (rawCar is String && rawCar.isNotEmpty) {
      carDetails =
          CarDetailsModel.fromJson(jsonDecode(rawCar) as Map<String, dynamic>);
    } else if (rawCar is Map) {
      carDetails = CarDetailsModel.fromJson(rawCar as Map<String, dynamic>);
    }

    return ProfileModel(
      userId: j['userId'] ?? j['_id'] ?? '',
      userEmail: j['userEmail'] ?? '',
      isDriver: j['isDriver'] == true,
      gender: j['gender'] ?? '',
      location: location,
      phoneNumber: j['phoneNumber'] ?? '',
      profilePicture: j['profilePicture'],
      carPicture: j['carPicture'],
      driverLicense: j['driverLicense'],
      carDetails: carDetails,
      maritalStatus: j['maritalStatus'],
      yoe: j['YOE']?.toString(),
      currentLocation: j['currentLocation'],
      languageSpoken: j['languageSpoken'],
      gearType: j['gearType'],
      vehicleType: j['vehicleType'],
      driverRoles: (j['driverRoles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      interstate: j['interstate'] == true,
      question: j['question'],
      ratings: (j['ratings'] as num?)?.toDouble() ?? 0,
      verified: j['verified'] == true,
    );
  }

  ProfileEntity toEntity() => ProfileEntity(
        userId: userId,
        userEmail: userEmail,
        isDriver: isDriver,
        gender: gender,
        role: isDriver ? 'driver' : 'client',
        location: location.toEntity(),
        phoneNumber: phoneNumber,
        profilePicture: profilePicture,
        carPicture: carPicture,
        driverLicense: driverLicense,
        carDetails: carDetails?.toEntity(),
        maritalStatus: maritalStatus,
        yoe: yoe,
        currentLocation: currentLocation,
        languageSpoken: languageSpoken,
        gearType: gearType,
        vehicleType: vehicleType,
        driverRoles: driverRoles,
        interstate: interstate,
        question: question,
        ratings: ratings,
        verified: verified,
      );
}
