import 'package:get_it/get_it.dart';
import 'package:findom/services/notification_service.dart';
import 'package:findom/services/theme_provider.dart';
import 'package:findom/services/post_service.dart';
import 'package:findom/services/network_service.dart';
import 'package:findom/services/search_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => ThemeProvider());
  locator.registerLazySingleton(() => NotificationService());
  locator.registerLazySingleton(() => PostService());
  locator.registerLazySingleton(() => NetworkService());
  locator.registerLazySingleton(() => SearchService());
}
