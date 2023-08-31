class LicensePlate {
  final int id;
  final String code;
  final double longitude;
  final double latitude;
  final String imageUrl;
  final bool hasInfractions;
  final bool takenActions;

  LicensePlate(
      {required this.id,
      required this.code,
      required this.longitude,
      required this.latitude,
      required this.imageUrl,
      required this.hasInfractions,
      required this.takenActions});
}
