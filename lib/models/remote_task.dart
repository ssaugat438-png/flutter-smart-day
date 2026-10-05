/// Represents a remote task or reminder fetched for demonstration purposes.
class RemoteTask {
  final int id;
  final int userId;
  final String title;
  final bool completed;

  const RemoteTask({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  factory RemoteTask.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? 'Untitled Task';
    // Capitalize first letter for neat presentation
    final formattedTitle = title.isNotEmpty
        ? '${title[0].toUpperCase()}${title.substring(1)}'
        : title;

    return RemoteTask(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 1,
      title: formattedTitle,
      completed: json['completed'] as bool? ?? false,
    );
  }
}
