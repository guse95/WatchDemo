class Booking {
  final int id;
  final int bookerId;
  final int resourceId;
  final String status;
  final DateTime createdAt;
  final DateTime lastUpdateAt;
  final DateTime bookedFrom;
  final DateTime bookedTo;

  const Booking({
    required this.id,
    required this.bookerId,
    required this.resourceId,
    required this.status,
    required this.createdAt,
    required this.lastUpdateAt,
    required this.bookedFrom,
    required this.bookedTo,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      bookerId: json['booker_id'],
      resourceId: json['resource_id'],
      status: json['status'],
      createdAt: _parseDateTimeToMinutes(json['created_at']),
      lastUpdateAt: _parseDateTimeToMinutes(json['last_update_at']),
      bookedFrom: _parseDateTimeToMinutes(json['booked_from']),
      bookedTo: _parseDateTimeToMinutes(json['booked_to']),
    );
  }

  static DateTime _parseDateTimeToMinutes(String value) {
    final dateTime = DateTime.parse(value);

    return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.minute);
  }

  @override
  String toString() {
    return 'Booking('
        'id: $id, '
        'bookerId: $bookerId, '
        'resourceId: $resourceId, '
        'status: $status, '
        'createdAt: $createdAt, '
        'lastUpdateAt: $lastUpdateAt, '
        'bookedFrom: $bookedFrom, '
        'bookedTo: $bookedTo'
        ')';
  }
}
