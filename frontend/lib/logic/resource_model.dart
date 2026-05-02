class Resource {
  final int id;
  final String name;
  final String type;
  final int? capacity;
  final String? location;
  final String? imageUrl;

  Resource({
    required this.id,
    required this.name,
    required this.type,
    this.capacity,
    this.location,
    this.imageUrl,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      capacity: json['capacity'],
      location: json['location'],
      imageUrl: json['imageUrl'],
    );
  }
}

