class Infraction {
  final int id;
  final String name;
  String? infractionCode;
  String? ballotNumber;
  final String level;
  final double fine;
  final int licensePlateId;
  DateTime? date;

  Infraction(
      {required this.id,
      this.infractionCode,
      this.ballotNumber,
      required this.name,
      required this.level,
      required this.fine,
      required this.licensePlateId,
      this.date});
}
