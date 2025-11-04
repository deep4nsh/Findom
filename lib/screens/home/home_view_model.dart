import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeViewModel extends ChangeNotifier {
  bool hasNewNotification = true;
  bool _isDarkMode = false;
  String userName = "Loading...";
  List<String> tasks = [];
  Map<String, bool> taskStatus = {};
  Timer? resetTimer;

  bool get isDarkMode => _isDarkMode;

  HomeViewModel() {
    loadDarkModePreference();
    fetchUserName();
    loadTasks();
    scheduleMidnightReset();
  }

  void scheduleMidnightReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final diff = tomorrow.difference(now);
    resetTimer = Timer(diff, () {
      taskStatus.updateAll((key, value) => false);
      saveTasks();
      scheduleMidnightReset(); // reschedule for next day
      notifyListeners();
    });
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTasks = prefs.getStringList('tasks') ?? ["Submit Form 10E", "Pay Advance Tax", "File GSTR-3B"];
    final storedStatus = prefs.getStringList('taskStatus') ?? List.filled(storedTasks.length, "false");

    tasks = storedTasks;
    taskStatus = {
      for (int i = 0; i < tasks.length; i++) tasks[i]: storedStatus[i] == "true"
    };
    notifyListeners();
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks', tasks);
    await prefs.setStringList('taskStatus', tasks.map((e) => taskStatus[e]! ? "true" : "false").toList());
  }

  Future<void> loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> saveDarkModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
    _isDarkMode = value;
    notifyListeners();
  }

  Future<void> fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        userName = doc['name'] ?? 'User';
      } catch (e) {
        userName = 'User';
      }
      notifyListeners();
    }
  }

  String getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void toggleTaskStatus(String task, bool? value) {
    if (value != null) {
      taskStatus[task] = value;
      saveTasks();
      notifyListeners();
    }
  }

  void addTask(String newTask) {
    if (newTask.isNotEmpty) {
      tasks.add(newTask);
      taskStatus[newTask] = false;
      saveTasks();
      notifyListeners();
    }
  }

  void removeTask(String task) {
    tasks.remove(task);
    taskStatus.remove(task);
    saveTasks();
    notifyListeners();
  }
  
  void setNotification(bool value) {
      hasNewNotification = value;
      notifyListeners();
  }

  @override
  void dispose() {
    resetTimer?.cancel();
    super.dispose();
  }
}
