class Note {
  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;
  final int color;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "content": content,
      "updatedAt": updatedAt.toIso8601String(),
      "color": color,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map["id"]?.toString() ?? DateTime.now().toString(),
      title: map["title"]?.toString() ?? "",
      content: map["content"]?.toString() ?? "",
      updatedAt: _parseDate(map["updatedAt"]),
      color: map["color"] is int ? map["color"] : 0xFFFFFFFF,
    );
  }

  static DateTime _parseDate(dynamic value) {
    try {
      if (value == null) return DateTime.now();
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}