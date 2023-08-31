class Infraction {
  final int id;
  final String name;
  final String level;
  final double fine;
  final int licensePlateId;
  
  Infraction(
      {required this.id,
      required this.name,
      required this.level,
      required this.fine,
      required this.licensePlateId});
}