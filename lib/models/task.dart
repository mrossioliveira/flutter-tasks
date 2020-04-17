class Task {
  final int id;
  final String title;
  final String description;
  final String status;
  final bool important;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task(
      {this.id,
      this.title,
      this.description,
      this.status,
      this.important,
      this.createdAt,
      this.updatedAt});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      important: json['important'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
