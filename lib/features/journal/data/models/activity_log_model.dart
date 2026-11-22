import '../../domain/entities/activity_log.dart';

class ActivityLogModel extends ActivityLog {
  const ActivityLogModel({
    required super.id,
    required super.journalId,
    required super.actionType,
    required super.timestamp,
    required super.dateStr,
  });

  factory ActivityLogModel.fromEntity(ActivityLog log) {
    return ActivityLogModel(
      id: log.id,
      journalId: log.journalId,
      actionType: log.actionType,
      timestamp: log.timestamp,
      dateStr: log.dateStr,
    );
  }

  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    return ActivityLogModel(
      id: map['id'] as String,
      journalId: map['journal_id'] as String,
      actionType: map['action_type'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      dateStr: map['date_str'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'journal_id': journalId,
      'action_type': actionType,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'date_str': dateStr,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) => ActivityLogModel.fromMap(json);
}
