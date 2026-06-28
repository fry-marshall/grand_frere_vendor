class School {
  const School({
    required this.id,
    required this.name,
    required this.sigle,
    required this.address,
    this.popular = false,
  });

  final String id;
  final String name;
  final String sigle;
  final String address;
  final bool popular;

  String get city {
    final parts = address.split(', ');
    return parts.length > 1 ? parts.last.trim() : address;
  }
}
