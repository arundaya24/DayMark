class ActivityLog {
  final String id;
  final String journalId;
  final String actionType; // 'create', 'update'
  final DateTime timestamp;
  final String dateStr; // 'YYYY-MM-DD' (device local date)

  const ActivityLog({
    required this.id,
    required this.journalId,
    required this.actionType,
    required this.timestamp,
    required this.dateStr,
  });
}
