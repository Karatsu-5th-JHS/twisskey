
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService
      ._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _androidInitializationSettings = const AndroidInitializationSettings('ic_launcher');

  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal() {
    init();
  }

  void init() async {
    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: _androidInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void createNotification(int count, int i, int id, String title,bool progress,body) {
    //show the notifications.
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'progress channel', 'progress channel',
        channelDescription: body,
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: progress,
        maxProgress: count,
        progress: i);
    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    _flutterLocalNotificationsPlugin.show(id, title,
        body, platformChannelSpecifics,
        payload: 'item x');
  }

  void cancel(int id){
    _flutterLocalNotificationsPlugin.cancel(id);
  }
}