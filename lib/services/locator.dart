import 'package:get_it/get_it.dart';
import 'package:findom/services/notification_service.dart';
import 'package:findom/services/theme_provider.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => ThemeProvider());
  locator.registerLazySingleton(() => NotificationService());
}
