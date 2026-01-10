class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String sender;
  final DateTime date;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.sender,
    required this.date,
    this.isRead = false,
  });
}
