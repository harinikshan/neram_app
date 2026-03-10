import 'package:uuid/uuid.dart';

class BookmarkModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> timezoneIds;
  final String masterTimezoneId;
  final int previewOffsetMinutes;

  const BookmarkModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.timezoneIds,
    required this.masterTimezoneId,
    this.previewOffsetMinutes = 0,
  });

  factory BookmarkModel.create({
    required String name,
    required List<String> timezoneIds,
    required String masterTimezoneId,
    int previewOffsetMinutes = 0,
  }) {
    return BookmarkModel(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      timezoneIds: timezoneIds,
      masterTimezoneId: masterTimezoneId,
      previewOffsetMinutes: previewOffsetMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'timezoneIds': timezoneIds,
        'masterTimezoneId': masterTimezoneId,
        'previewOffsetMinutes': previewOffsetMinutes,
      };

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      timezoneIds: (json['timezoneIds'] as List).cast<String>(),
      masterTimezoneId: json['masterTimezoneId'] as String,
      previewOffsetMinutes: (json['previewOffsetMinutes'] as int?) ?? 0,
    );
  }
}
