import 'dart:typed_data';

class LicensePlate {
  final int id;
  final String code;
  final double longitude;
  final double latitude;
  final Uint8List imageUrl;
  final bool hasInfractions;
  final bool takenActions;
  final int userId;
  
  LicensePlate(
      {required this.id,
      required this.code,
      required this.longitude,
      required this.latitude,
      required this.imageUrl,
      required this.hasInfractions,
      required this.takenActions,
      required this.userId});
}
