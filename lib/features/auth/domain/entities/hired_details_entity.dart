// lib/features/auth/domain/entities/hired_details_entity.dart

class HiredDetailsEntity {
  final String durationType;
  final String minimumSalary;
  final bool interstateTravel;
  final String typeOfCar;
  final String transmission;
  final String preference;

  const HiredDetailsEntity({
    required this.durationType,
    required this.minimumSalary,
    required this.interstateTravel,
    required this.typeOfCar,
    required this.transmission,
    required this.preference,
  });

  Map<String, dynamic> toJson() => {
        'durationType': durationType,
        'minimumSalary': minimumSalary,
        'interstateTravel': interstateTravel,
        'typeOfCar': typeOfCar,
        'transmission': transmission,
        'preference': preference,
      };
}
