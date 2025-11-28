import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findom/models/reminder_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ReminderService() {
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> addReminder(Reminder reminder) async {
    DocumentReference docRef = await _firestore
        .collection('users')
        .doc(reminder.userId)
        .collection('reminders')
        .add(reminder.toMap());
    
    _scheduleNotification(reminder.copyWith(id: docRef.id));
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _firestore
        .collection('users')
        .doc(reminder.userId)
        .collection('reminders')
        .doc(reminder.id)
        .update(reminder.toMap());
    
    if (!reminder.isCompleted) {
       _scheduleNotification(reminder);
    } else {
      _cancelNotification(reminder.id);
    }
  }

  Future<void> deleteReminder(String userId, String reminderId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(reminderId)
        .delete();
    _cancelNotification(reminderId);
  }

  Stream<List<Reminder>> getReminders(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reminder.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    if (reminder.dateTime.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description,
      tz.TZDateTime.from(reminder.dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Reminders',
          channelDescription: 'Channel for reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _cancelNotification(String reminderId) async {
    await _notificationsPlugin.cancel(reminderId.hashCode);
  }
}
