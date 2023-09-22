import 'dart:typed_data';

class LicensePlate {
  final int id;
  final String code;
  final double longitude;
  final double latitude;
  final Uint8List imageUrl;
  bool hasInfractions;
  bool takenActions;
  DateTime? createdAt;
  final int userId;

  LicensePlate(
      {required this.id,
      required this.code,
      required this.longitude,
      required this.latitude,
      required this.imageUrl,
      required this.hasInfractions,
      required this.takenActions,
      this.createdAt,
      required this.userId});
}
