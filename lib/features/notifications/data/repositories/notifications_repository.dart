import '../models/notification_model.dart';

abstract class NotificationsRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  @override
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      NotificationModel(
        id: '1',
        title: 'Blithes Marketing Team...',
        body: 'Body text ody text ody text ody text ody text ody text ody text ody text...',
        sender: 'Blithes Marketing Team',
        date: DateTime.now(),
      ),
    ];
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
