class Note {
  final String day;
  final String date;
  final String title;
  final String author;
  final String time;
  final String meetingType;
  final String? note;
  final String groupId;

  Note({
    required this.day,
    required this.date,
    required this.title,
    required this.author,
    required this.time,
    required this.meetingType,
    this.note,
    required this.groupId,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      day: json['day'],
      date: json['date'],
      title: json['title'],
      author: json['author'],
      time: json['time'],
      meetingType: json['type'],
      note: json['notes'] != null
          ? (json['notes'] is List
              ? (json['notes'] as List).join('\n')
              : json['notes'].toString())
          : null,
      groupId: json['groupId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'date': date,
        'title': title,
        'author': author,
        'time': time,
        'type': meetingType,
        if (note != null) 'notes': note!.split('\n'),
        'groupId': groupId,
      };
}
