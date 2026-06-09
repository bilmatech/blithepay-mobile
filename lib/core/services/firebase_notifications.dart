import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotifications {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String> getFcmToken() async {
    return (await _messaging.getToken()) ?? '';
  }
}
