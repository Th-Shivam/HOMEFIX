class Worker {
  final String name;
  final String phone;
  final String type; // 'plumber' or 'electrician'
  final double rating;
  final String location;
  final bool available;

  Worker({
    required this.name,
    required this.phone,
    required this.type,
    required this.rating,
    required this.location,
    required this.available,
  });
}
