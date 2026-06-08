import 'package:frontend/logic/resource_model.dart';

class Booking {
  final int id;
  final int bookerId;
  final int resourceId;
  final String status;
  final String description;
  final DateTime createdAt;
  final DateTime lastUpdateAt;
  final DateTime bookedFrom;
  final DateTime bookedTo;
  final Resource? resource;

  const Booking({
    required this.id,
    required this.bookerId,
    required this.resourceId,
    required this.status,
    required this.createdAt,
    required this.lastUpdateAt,
    required this.bookedFrom,
    required this.bookedTo,
    required this.description,
    this.resource,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final resourceJson = json['resource'];

    return Booking(
      id: json['id'],
      bookerId: json['booker_id'],
      resourceId: json['resource_id'],
      status: json['status'],
      description: json['description'],
      createdAt: _parseDateTimeToMinutes(json['created_at']),
      lastUpdateAt: _parseDateTimeToMinutes(json['last_update_at']),
      bookedFrom: _parseDateTimeToMinutes(json['booked_from']),
      bookedTo: _parseDateTimeToMinutes(json['booked_to']),
      resource: resourceJson is Map
          ? Resource.fromJson(Map<String, dynamic>.from(resourceJson))
          : null,
    );
  }

  static DateTime _parseDateTimeToMinutes(String value) {
    final dateTime = DateTime.parse(value);

    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );
  }

  @override
  String toString() {
    return 'Booking('
        'id: $id, '
        'bookerId: $bookerId, '
        'resourceId: $resourceId, '
        'status: $status, '
        'desc: $description, '
        'createdAt: $createdAt, '
        'lastUpdateAt: $lastUpdateAt, '
        'bookedFrom: $bookedFrom, '
        'bookedTo: $bookedTo, '
        'resource: $resource'
        ')';
  }
}
