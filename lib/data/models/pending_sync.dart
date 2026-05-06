class PendingSync {
  final int? id;
  final String operation;
  final String payload;
  final DateTime createdAt;

  const PendingSync({
    this.id,
    required this.operation,
    required this.payload,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'operation': operation,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
      };

  factory PendingSync.fromMap(Map<String, Object?> map) {
    return PendingSync(
      id: map['id'] as int?,
      operation: map['operation'] as String,
      payload: map['payload'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
