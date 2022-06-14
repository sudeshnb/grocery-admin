
class AppNotification {
  final String? title;

  final String? body;

  AppNotification({required this.title, required this.body});

  factory AppNotification.fromMap(Map data) {
    return AppNotification(title: data['title'], body: data['body']);
  }
}
